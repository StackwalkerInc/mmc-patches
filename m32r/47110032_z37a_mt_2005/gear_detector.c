// SPDX-License-Identifier: GPL-3.0-or-later
#include <stdint.h>
#include <memaccess.h>
#include <memory_map.h>
#include <fmath.h>
#include <gpio.h>
#include <run_state_flags.h>

#include "gear_detector.h"

typedef uint16_t gear_ratio_t;

struct gear_threshold {
	gear_ratio_t low_out;
	gear_ratio_t low_in;
	gear_ratio_t high_in;
	gear_ratio_t high_out;
};

static const uint16_t flash_init_gear_unstable = 2;
static const uint16_t flash_torque_stability_threshold = 5;

#define GEAR_THRESHOLD_DEF(target, inth, outth)                                                                        \
	{                                                                                                                  \
	    .low_in = target - inth,                                                                                       \
	    .low_out = target - outth,                                                                                     \
	    .high_in = target + inth,                                                                                      \
	    .high_out = target + outth,                                                                                    \
	}

static const struct gear_threshold flash_gear_thresholds[5] = {
    GEAR_THRESHOLD_DEF(8300, 500, 1000),  GEAR_THRESHOLD_DEF(15400, 600, 1200), GEAR_THRESHOLD_DEF(21900, 600, 1200),
    GEAR_THRESHOLD_DEF(28700, 600, 1200), GEAR_THRESHOLD_DEF(35300, 600, 1200),
};

static void update_gear_flags()
{
	uint16_t l_gear_ratio = s16_divu32_16(readu16(can_vehicle_speed) << 16, readu16(engine_rpm));
	uint16_t l_cgear = readu8(calculated_gear);
	writeu16(l_gear_ratio, gear_detector_gratio);
	if ((l_cgear >= 1) && (l_cgear <= 5) && (l_gear_ratio > flash_gear_thresholds[l_cgear - 1].low_out)
	    && (l_gear_ratio < flash_gear_thresholds[l_cgear - 1].high_out)) {
		return;
	}
	unsigned i;
	l_cgear = 0;
	for (i = 0; i < 5; ++i) {
		if ((l_gear_ratio > flash_gear_thresholds[i].low_in) && (l_gear_ratio < flash_gear_thresholds[i].high_in)) {
			l_cgear = i + 1;
			break;
		}
	}
	writeu8(l_cgear, calculated_gear);
}

void update_current_gear()
{
	uint_fast8_t l_cgear_prev = readu8(calculated_gear);
	update_gear_flags();
	if (l_cgear_prev != readu8(calculated_gear)) {
		writeu16(flash_init_gear_unstable, decays_x1_gear_unstable);
	}
	uint_fast16_t l_torque = readu16(engine_torque_output_with_losses);
	if ((l_torque < 128 + flash_torque_stability_threshold) && (l_torque > 128 - flash_torque_stability_threshold)) {
		writeu16(flash_init_gear_unstable, decays_x1_gear_torque_insufficient);
	}

	if (!readu16(vehicle_movement_decay) || (readu16(run_state_flags) & RUN_STATE_FLAGS_NOT_RUNNING)) {
		writeu8(NEUTRAL_GEAR, current_gear);
	} else if (IS_CLUTCH_DEPRESSED) {
		writeu8(CLUTCHED_INDEFINITE_GEAR, current_gear);
	} else if (!readu16(decays_x1_gear_unstable) && !readu16(decays_x1_gear_torque_insufficient)) {
		writeu8(readu8(calculated_gear), current_gear);
	}
}
