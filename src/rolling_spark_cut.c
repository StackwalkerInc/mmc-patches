// SPDX-License-Identifier: GPL-3.0-or-later
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;

#define CYLINDER_ROW_SIZE 16

#define LAUNCH_CONTROL_THRESHOLD 8000
#define LAUNCH_CONTROL_THRESHOLD_SUB125RPM (LAUNCH_CONTROL_THRESHOLD + 125)
#define LAUNCH_CONTROL_THRESHOLD_SUB250RPM (LAUNCH_CONTROL_THRESHOLD + 250)
#define LAUNCH_CONTROL_THRESHOLD_SUB375RPM (LAUNCH_CONTROL_THRESHOLD + 375)
#define LAUNCH_CONTROL_THRESHOLD_SUB500RPM (LAUNCH_CONTROL_THRESHOLD + 500)

const uint8_t spark_cut_table[3][CYLINDER_ROW_SIZE] = {
    {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1},
    {1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1},
};

const uint16_t spark_cut_thresholds[4] = {80, 60, 40, 20};

uint8_t cylinder_index;

/*defined in revolution_limit.c*/
uint16_t revolution_limit;

/*from description.ld*/
extern uint16_t shaft_period1_copy_dline0;

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

bool do_spark_cut_in_interrupt(uint16_t revolution_period)
{
	cylinder_index = (cylinder_index + 1) % CYLINDER_ROW_SIZE;
	if (shaft_period1_copy_dline0 < revolution_limit) {
		return true;
	}
	if (shaft_period1_copy_dline0 >= revolution_limit + spark_cut_thresholds[0]) {
		return false;
	}
	const uint8_t *spark_cut_row;
	if (shaft_period1_copy_dline0 < revolution_limit + spark_cut_thresholds[1]) {
		spark_cut_row = spark_cut_table[0];
	}
	if (shaft_period1_copy_dline0 < revolution_limit + spark_cut_thresholds[2]) {
		spark_cut_row = spark_cut_table[1];
	}
	if (shaft_period1_copy_dline0 < revolution_limit + spark_cut_thresholds[3]) {
		spark_cut_row = spark_cut_table[2];
	}
	return spark_cut_row[cylinder_index];
}

extern uint16_t get_coil_dwell(uint16_t p0);

uint16_t new_get_coil_dwell_in_interrupt(uint16_t p0)
{
	if (do_spark_cut_in_interrupt(p0)) {
		return 0;
	}
	return get_coil_dwell(p0);
}
