// SPDX-License-Identifier: GPL-3.0-or-later
#include <stdint.h>

/* CAN slot-12 RX payload (physical 0x7E0) and slot-15 RX payload (functional 0x7DF). */
extern uint8_t canrx12_data[];
extern uint8_t canrx15_data[];
/* Slot-5 (0x7E8) TX payload: contiguous big-endian uint16_t slots; uint8_t view
 * gives the CAN byte sequence. */
extern uint16_t cantx5_data0;
/* Original CAN dispatcher, bound per-ROM via description.ld PROVIDE. */
extern unsigned canrx12_15_process(unsigned slot);

#ifdef FEATURE_OBD_MODE_23
#include "mode_23_read_memory_by_address_can.c"
#endif
#ifdef FEATURE_OBD_MODE_3D
#include "mode_3d_write_memory_by_address_can.c"
#endif

unsigned canrx12_15_process_trampoline(unsigned slot)
{
	uint8_t *rx = (slot == 2) ? canrx12_data : canrx15_data;
	switch (rx[1]) {
#ifdef FEATURE_OBD_MODE_23
	case 0x23:
		return mode_23_can(rx);
#endif
#ifdef FEATURE_OBD_MODE_3D
	case 0x3d:
		return mode_3d_can(rx);
#endif
	default:
		return canrx12_15_process(slot);
	}
}
