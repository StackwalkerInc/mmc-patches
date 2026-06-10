// SPDX-License-Identifier: GPL-3.0-or-later
// Standalone VIN-guard module for Z27AG ROMs. Provides obd_kline_rest_handler
// (dispatches mode A1), prestart_checks, and injected_regen_crankshaft_rotation_decays.
// Compiled once per ROM — no feature-flag variability, no shared-object collision.
#include <stdint.h>

/* K-Line MUT frame buffers (uint16_t slot per byte). */
extern uint16_t sio0_rx_buffer[];
extern uint16_t sio0_tx_buffer[];
extern uint16_t sio0_tx_count;

#include "vin_guard_data.c"
#include "mode_a1_vin_guard.c"

unsigned obd_kline_rest_handler(void)
{
	switch (sio0_rx_buffer[3] & 0xff) {
	case 0xa1:
		mode_a1_kline();
		break;
	}
	return sio0_tx_count;
}
