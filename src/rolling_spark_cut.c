// SPDX-License-Identifier: GPL-3.0-or-later

#include "stdint.h"

#define CYLINDER_ROW_SIZE 16

#define LAUNCH_CONTROL_THRESHOLD 8000
#define LAUNCH_CONTROL_THRESHOLD_SUB125RPM (LAUNCH_CONTROL_THRESHOLD + 125)
#define LAUNCH_CONTROL_THRESHOLD_SUB250RPM (LAUNCH_CONTROL_THRESHOLD + 250)
#define LAUNCH_CONTROL_THRESHOLD_SUB375RPM (LAUNCH_CONTROL_THRESHOLD + 375)
#define LAUNCH_CONTROL_THRESHOLD_SUB500RPM (LAUNCH_CONTROL_THRESHOLD + 500)

const uint16_t spark_cut_masks[3] = {
    0b1000010000100001,
    0b1010010110100101,
    0b1110110110110111,
};

uint8_t cylinder_index;

/*defined in revolution_limit.c*/
uint16_t revolution_limit;

const volatile uint16_t flash_launch_control_rpm_limit = 0x3da / 2;
const volatile uint16_t flash_revolution_limit = 0x3da;
const volatile uint16_t flash_launch_control_speed_limit = 0x28;

extern uint16_t vehicle_speed_hires;

void update_revolution_limit(void)
{
	if (vehicle_speed_hires < flash_launch_control_speed_limit) {
		revolution_limit = flash_launch_control_rpm_limit;
	} else {
		revolution_limit = flash_revolution_limit;
	}
}

unsigned do_spark_cut_in_interrupt(uint_fast16_t revolution_period)
{
	uint8_t idx = (cylinder_index + 1) % CYLINDER_ROW_SIZE;
	cylinder_index = idx;
	if (revolution_period < revolution_limit) {
		return 1;
	}
	const uint_fast16_t delta = revolution_period - revolution_limit;
	if (delta >= 60) {
		return 0;
	}

	const unsigned mask_idx = (delta * 13) >> 8;
	const unsigned mask = spark_cut_masks[mask_idx];

	return (mask >> idx) & 1;
}

extern uint16_t get_coil_dwell(uint16_t p0);

uint16_t new_get_coil_dwell_in_interrupt(uint16_t p0)
{
	if (do_spark_cut_in_interrupt(p0)) {
		return 0;
	}
	return get_coil_dwell(p0);
}
