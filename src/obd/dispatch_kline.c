// SPDX-License-Identifier: GPL-3.0-or-later
#include <stdint.h>

/* K-Line MUT frame buffers (uint16_t slot per byte). */
extern uint16_t sio0_rx_buffer[];
extern uint16_t sio0_tx_buffer[];
extern uint16_t sio0_tx_count;

/* Service fragment files — included, not separately compiled.
 * Each is guarded by a FEATURE_OBD_* macro defined per-ROM in the Makefile. */
#ifdef FEATURE_OBD_MODE_23
#include "mode_23_read_memory_by_address_kline.c"
#endif
#ifdef FEATURE_OBD_MODE_3D
#include "mode_3d_write_memory_by_address_kline.c"
#endif
#ifdef FEATURE_OBD_VIN_GUARD
#include "vin_guard_data.c"
#include "mode_a1_vin_guard.c"
#endif

unsigned obd_kline_rest_handler(void)
{
	switch (sio0_rx_buffer[3] & 0xff) {
#ifdef FEATURE_OBD_MODE_23
	case 0x23:
		mode_23_kline();
		break;
#endif
#ifdef FEATURE_OBD_MODE_3D
	case 0x3d:
		mode_3d_kline();
		break;
#endif
#ifdef FEATURE_OBD_VIN_GUARD
	case 0xa1:
		mode_a1_kline();
		break;
#endif
	}
	return sio0_tx_count;
}
