// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef GEAR_DETECTOR_DATA_H
#define GEAR_DETECTOR_DATA_H

#include <stdint.h>

extern uint8_t current_gear;
extern uint8_t calculated_gear;

typedef uint16_t gear_ratio_t;

struct gear_threshold {
	gear_ratio_t low_out;
	gear_ratio_t low_in;
	gear_ratio_t high_in;
	gear_ratio_t high_out;
};

#if MACHINE_Z37AMT
extern const struct gear_threshold flash_gear_thresholds[5];
#else
extern const struct gear_threshold flash_gear_thresholds[6];
#endif

extern const uint16_t flash_init_gear_unstable;
#endif /*GEAR_DETECTOR_DATA_H*/
