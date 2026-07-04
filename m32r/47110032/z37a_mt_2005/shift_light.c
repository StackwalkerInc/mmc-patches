// SPDX-License-Identifier: GPL-3.0-or-later
#include "shift_light.h"
#include "gear_detector_data.h"

extern uint16_t engine_rpm;

void update_shift_light()
{
	if (engine_rpm >= flash_shift_light_engine_rpm[current_gear]) {
		shift_light_state = SHIFT_LIGHT_STATE_UP;
	} else {
		shift_light_state = SHIFT_LIGHT_STATE_NONE;
	}
}
