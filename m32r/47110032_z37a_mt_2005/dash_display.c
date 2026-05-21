// SPDX-License-Identifier: GPL-3.0-or-later
#include "stdint.h"

#include "shift_assist.h"
#include "mode_selector.h"
#include "memaccess.h"
#include "memory_map.h"
#include "launch_control.h"
#include "gear_detector.h"
#include "shift_light.h"

#define DASH_CONTROL_MODE_NONE 0
#define DASH_CONTROL_MODE_SELECTOR 1
#define DASH_CONTROL_SHIFT_ASSIST 2
#define DASH_CONTROL_LAUNCH 3
#define DASH_CONTROL_MODE_SELECTOR_FLASHING 4

const uint16_t flash_init_shift_recommended_flash_decay = 40;
const uint16_t flash_init_launch_control_flash_decay = 10;
const uint16_t flash_init_mode_selector_active2_flash_decay = 20;

static char gear_symbol(unsigned gear)
{
	return gear <= 6 ? '0' + gear : ' ';
}

static void update_dash_control_mode()
{
	if (IS_BIT_SET16(mode_selector_flags, MODE_SELECTOR_ACTIVE)) {
		writeu8(DASH_CONTROL_MODE_SELECTOR, dash_control_mode);
	} else if (IS_BIT_SET16(mode_selector_flags, MODE_SELECTOR_ACTIVE2)) {
		writeu8(DASH_CONTROL_MODE_SELECTOR_FLASHING, dash_control_mode);
	} else if (IS_BIT_SET16(launch_control_flags, LAUNCH_CONTROL_ON)) {
		writeu8(DASH_CONTROL_LAUNCH, dash_control_mode);
	} else if (shift_light_state != SHIFT_LIGHT_STATE_NONE) {
		writeu8(DASH_CONTROL_SHIFT_ASSIST, dash_control_mode);
	} else {
		writeu8(DASH_CONTROL_MODE_NONE, dash_control_mode);
	}
}

extern const uint8_t flash_can_tx2_done_index[7];
extern const uint8_t flash_can_tx2_done_mask[7];
extern void can_tx2_request(uint8_t p_slot);
extern void can0_update_bus_state();
extern void can0_update_tx_data();

static char mode_symbol(unsigned mode)
{
	return !mode ? 'A' : (mode <= 7 ? '0' + mode - 1 : ' ');
}

static unsigned is_flash_phase1(unsigned p_period)
{
	if (!readu16(decays_x1_dash_symbol2_flasher)) {
		writeu16(p_period, decays_x1_dash_symbol2_flasher);
	}
	return readu16(decays_x1_dash_symbol2_flasher) >= p_period / 2;
}

#define DASH_NO_ARROW 0
#define DASH_UP_ARROW 24
#define DASH_DOWN_ARROW 25

void update_dash_display()
{
	pushi();
	volatile uint8_t *l_flag_ptr =
	    (volatile uint8_t *)(TO_FULL_POINTER(can_tx2_done_flags) + flash_can_tx2_done_index[1]);
	*l_flag_ptr &= ~flash_can_tx2_done_mask[1];
	popi();

	update_shift_light();
	update_dash_control_mode();
	switch (readu8(dash_control_mode)) {
	case DASH_CONTROL_MODE_SELECTOR: {
		writeu8(mode_symbol(readu16(mode_idx)), dash_symbol);
		writeu8(0, dash_symbol2);
	} break;
	case DASH_CONTROL_MODE_SELECTOR_FLASHING: {
		uint_fast16_t idx = readu16(mode_idx);
		writeu8(is_flash_phase1(flash_init_mode_selector_active2_flash_decay) ? (idx ? 'A' : ' ') : mode_symbol(idx),
		        dash_symbol);
		writeu8(0, dash_symbol2);
	} break;
	case DASH_CONTROL_LAUNCH: {
		if (is_flash_phase1(flash_init_launch_control_flash_decay)) {
			writeu8(' ', dash_symbol);
			writeu8(DASH_UP_ARROW, dash_symbol2);
		} else {
			writeu8('A', dash_symbol);
			writeu8(DASH_NO_ARROW, dash_symbol2);
		}
	} break;
	case DASH_CONTROL_SHIFT_ASSIST:
		writeu8(gear_symbol(readu16(current_gear)), dash_symbol);
		if (is_flash_phase1(flash_init_shift_recommended_flash_decay)) {
			writeu8(DASH_NO_ARROW, dash_symbol2);
		} else {
			writeu8(shift_light_state == SHIFT_LIGHT_STATE_UP ? DASH_UP_ARROW : DASH_DOWN_ARROW, dash_symbol2);
		}
		break;
	default:
// TODO: reverse
#define IS_REVERSE_ACTIVE 0
		if (IS_REVERSE_ACTIVE) {
			writeu8('R', dash_symbol);
		} else if (!readu16(vehicle_movement_decay)) {
			writeu8('N', dash_symbol);
		} else {
			writeu8(gear_symbol(readu8(current_gear)), dash_symbol);
		}
		writeu8(0, dash_symbol2);
	}
	writeu16(readu16(map_engine_load), dash_symbol5);
	can_tx2_request(1);
}

// instead of 0x2ba70 at 4e1bc
void can_topcall_replacement()
{
	can0_update_bus_state();
	can0_update_tx_data();

	update_current_gear();

	update_dash_display();
}
