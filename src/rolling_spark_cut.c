// SPDX-License-Identifier: GPL-3.0-or-later
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;

#define CYLINDER_ROW_SIZE 16

#define LAUNCH_CONTROL_THRESHOLD 8000
#define LAUNCH_CONTROL_THRESHOLD_SUB125RPM (LAUNCH_CONTROL_THRESHOLD + 125)
#define LAUNCH_CONTROL_THRESHOLD_SUB250RPM (LAUNCH_CONTROL_THRESHOLD + 250)
#define LAUNCH_CONTROL_THRESHOLD_SUB375RPM (LAUNCH_CONTROL_THRESHOLD + 375)
#define LAUNCH_CONTROL_THRESHOLD_SUB500RPM (LAUNCH_CONTROL_THRESHOLD + 500)

const uint8_t spark_cut_table[5][CYLINDER_ROW_SIZE] = {
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},

    {1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1},

    {1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1},

};

volatile uint8_t cylinder_index;
volatile uint8_t launch_control_active;

bool do_spark_cut_in_interrupt(uint16_t revolution_period)
{
	if (!launch_control_active) {
		return false;
	}
	// uint8_t *spark_cut_row = spark_cut_table[0];
	cylinder_index = (cylinder_index + 1) % CYLINDER_ROW_SIZE;
	//	if (revolution_period < LAUNCH_CONTROL_THRESHOLD_SUB250RPM) {
	//		if (revolution_period < LAUNCH_CONTROL_THRESHOLD_SUB125RPM) {
	//			if (revolution_period < LAUNCH_CONTROL_THRESHOLD) {
	//				return true;
	//			}
	//			return spark_cut_table[4][cylinder_index];
	//		} else {
	//			return spark_cut_table[3][cylinder_index];
	//		}
	//	} else {
	//		if (revolution_period < LAUNCH_CONTROL_THRESHOLD_SUB375RPM) {
	//			return spark_cut_table[2][cylinder_index];
	//		} else if (revolution_period < LAUNCH_CONTROL_THRESHOLD_SUB500RPM) {
	//			return spark_cut_table[1][cylinder_index];
	//		} else {
	//			return false;
	//		}
	//	}

	if (revolution_period < LAUNCH_CONTROL_THRESHOLD) {
		return true;
	}
	if (revolution_period < LAUNCH_CONTROL_THRESHOLD_SUB125RPM) {
		return spark_cut_table[4][cylinder_index];
	}
	if (revolution_period < LAUNCH_CONTROL_THRESHOLD_SUB250RPM) {
		return spark_cut_table[3][cylinder_index];
	}
	if (revolution_period < LAUNCH_CONTROL_THRESHOLD_SUB375RPM) {
		return spark_cut_table[2][cylinder_index];
	}
	if (revolution_period < LAUNCH_CONTROL_THRESHOLD_SUB500RPM) {
		return spark_cut_table[1][cylinder_index];
	}
	return false;
}

extern uint16_t get_coil_dwell(uint16_t p0);

uint16_t new_get_coil_dwell_in_interrupt(uint16_t p0)
{
	if (do_spark_cut_in_interrupt(p0)) {
		return 0;
	}
	return get_coil_dwell(p0);
}
