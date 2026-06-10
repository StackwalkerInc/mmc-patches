// SPDX-License-Identifier: GPL-3.0-or-later
// Included by dispatch_kline.c when FEATURE_OBD_MODE_23 is defined.
// sio0_rx_buffer, sio0_tx_buffer, sio0_tx_count declared in including TU.

#define MODE_23_KLINE_MAX_BYTES 10

static void mode_23_kline(void)
{
	uint32_t addr = ((uint32_t)(sio0_rx_buffer[4] & 0xff) << 16) | ((uint32_t)(sio0_rx_buffer[5] & 0xff) << 8)
	                | ((uint32_t)(sio0_rx_buffer[6] & 0xff));
	uint8_t count = sio0_rx_buffer[7] & 0xff;
	uint8_t i;

	if (count > MODE_23_KLINE_MAX_BYTES)
		count = MODE_23_KLINE_MAX_BYTES;

	{
		const uint8_t *src = (const uint8_t *)addr;
		for (i = 0; i < count; ++i)
			sio0_tx_buffer[4 + i] = src[i];
	}
	sio0_tx_count = 5 + count;
}
