// SPDX-License-Identifier: GPL-3.0-or-later

#include "stdint.h"

#define CYLINDER_ROW_SIZE 16

#define LAUNCH_CONTROL_THRESHOLD 8000
#define LAUNCH_CONTROL_THRESHOLD_SUB125RPM (LAUNCH_CONTROL_THRESHOLD + 125)
#define LAUNCH_CONTROL_THRESHOLD_SUB250RPM (LAUNCH_CONTROL_THRESHOLD + 250)
#define LAUNCH_CONTROL_THRESHOLD_SUB375RPM (LAUNCH_CONTROL_THRESHOLD + 375)
#define LAUNCH_CONTROL_THRESHOLD_SUB500RPM (LAUNCH_CONTROL_THRESHOLD + 500)

const uint16_t spark_cut_table[3] = {
    0b1000010000100001,
    0b1010010110100101,
    0b1110110110110111,
};

const uint16_t spark_cut_thresholds[3] = {60, 40, 20};

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
	if (delta > spark_cut_thresholds[0]) {
		return 0;
	}

	uint16_t mask;
	if (delta < 20) {
		mask = spark_cut_table[2];
	} else if (delta < 40) {
		mask = spark_cut_table[1];
	} else { // 40 <= delta < 60
		mask = spark_cut_table[0];
	}
	return (mask & (1 << idx));
}

extern uint16_t get_coil_dwell(uint16_t p0);

uint16_t new_get_coil_dwell_in_interrupt(uint16_t p0)
{
	if (do_spark_cut_in_interrupt(p0)) {
		return 0;
	}
	return get_coil_dwell(p0);
}
