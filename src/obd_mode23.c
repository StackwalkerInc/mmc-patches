// SPDX-License-Identifier: GPL-3.0-or-later
#include <stdint.h>

#include "obd_mode23.h"

/* K-Line MUT frame buffers (uint16_t slot per byte), per src/obd.c. */
extern uint16_t sio0_rx_buffer[];
extern uint16_t sio0_tx_buffer[];
extern uint16_t sio0_tx_count;

/* CAN slot-12 RX payload (service byte at [1]) and slot-5 TX payload. */
extern uint8_t canrx12_data[];
/* Slot-5 (0x7E8) TX payload: contiguous big-endian uint16_t slots; a uint8_t
 * view yields the CAN byte sequence. */
extern uint16_t cantx5_data0;

/* Original CAN dispatcher, bound per-ROM via description.ld PROVIDE. */
extern unsigned canrx12_15_process(void);

/* Read-only core: copy count bytes from a 24-bit address into dst.
 * No bounds check — read-only, matches the UDS spec and the Evo X reference. */
static void read_memory_by_address(uint32_t addr, uint8_t count, uint8_t *dst)
{
	const uint8_t *src = (const uint8_t *)addr;
	uint8_t i;
	for (i = 0; i < count; ++i)
		dst[i] = src[i];
}

void obd_mode23_kline(void)
{
	uint32_t addr = ((uint32_t)(sio0_rx_buffer[4] & 0xff) << 16) | ((uint32_t)(sio0_rx_buffer[5] & 0xff) << 8)
	                | ((uint32_t)(sio0_rx_buffer[6] & 0xff));
	uint8_t count = sio0_rx_buffer[7] & 0xff;
	uint8_t i;

	if (count > MODE23_KLINE_MAX_BYTES)
		count = MODE23_KLINE_MAX_BYTES;

	/* Copy directly into the uint16_t tx slots (one byte per slot). */
	{
		const uint8_t *src = (const uint8_t *)addr;
		for (i = 0; i < count; ++i)
			sio0_tx_buffer[4 + i] = src[i];
	}
	sio0_tx_count = 5 + count;
}

static unsigned obd_mode23_can(void)
{
	uint8_t *tx = (uint8_t *)&cantx5_data0;
	uint32_t addr = ((uint32_t)canrx12_data[2] << 16) | ((uint32_t)canrx12_data[3] << 8) | ((uint32_t)canrx12_data[4]);
	uint8_t count = canrx12_data[5];

	if (count > MODE23_CAN_MAX_BYTES) {
		/* NRC 0x14 responseTooLong, single frame. */
		tx[0] = 0x03; /* PCI: 3 payload bytes */
		tx[1] = 0x7f; /* negative response */
		tx[2] = 0x23; /* echoed service */
		tx[3] = 0x14; /* NRC */
		return 3;     /* r5 = negative */
	}

	tx[0] = count + 1; /* PCI: service + data length */
	tx[1] = 0x63;      /* positive response (0x23 + 0x40) */
	read_memory_by_address(addr, count, &tx[2]);
	return 1; /* r5 = positive */
}

unsigned canrx12_15_process_trampoline(void)
{
	if (canrx12_data[1] == 0x23)
		return obd_mode23_can();
	return canrx12_15_process();
}
