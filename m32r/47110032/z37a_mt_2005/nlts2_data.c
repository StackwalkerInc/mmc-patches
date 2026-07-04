// SPDX-License-Identifier: GPL-3.0-or-later
#include <fmath.h>

#include "nlts2_data.h"
#include "maps_desc.h"

#define NLTS_X_TO_RPM_ERROR(x) (32768 + (x) * 256 / 1000)
#define NLTS_X_TO_TORQUE_CORRECTION(x) (NLTS_NEUTRAL_TORQUE + (x))

const uint16_t flash_nlts_integral_torque_correction_limits[2] = {NLTS_NEUTRAL_TORQUE - 100, NLTS_NEUTRAL_TORQUE + 200};
const uint16_t flash_nlts_speed_averaging_rate = 128;
const uint16_t flash_nlts_rpm_overshoot = 64;
// const uint16_t flash_nlts_rpm_overshoot = 0;
const uint16_t flash_init_nlts_active_decay = 120;
const uint16_t flash_init_nlts_active_decay_partial_engagement = 40;
const uint16_t flash_nlts_delta_holdoff = 5;
const uint16_t flash_nlts_rpm_delta_threshold = 13; // 50rpm per 10ms is enough
const uint16_t flash_nlts_app_thresholds[2] = {250, 300};

const uint16_t flash_nlts_gear_ratios[7] = {0, 8300, 15400, 21900, 28700, 35300, 35300};

const uint16_t flash_nlts_gear_down_rpm_max = 256 * 2;
const uint8_t flash_nlts_gear_max = 5;

#if 0
const uint8_t flash_nlts_integral_divisor_multiu8a[8] = {
	16, 16, 32, 32,
	48, 48, 64, 64
};

const uint8_t flash_nlts_proportional_divisor_multiu8a[8] = {
	1, 2, 1, 2,
	1, 2, 1, 2,
};
#endif
const uint8_t flash_nlts_integral_divisor_multiu8a[8] = {
    16, 16, 16, 16, 16, 16, 16, 16,
};

const uint8_t flash_nlts_proportional_divisor_multiu8a[8] = {
    1, 1, 1, 1, 1, 1, 1, 1,
};

// #define NLTS_RPM_ERROR_AXIS_SIZE 11
#define NLTS_RPM_ERROR_AXIS_SIZE 9

#define temp_axis_src -13344

#define temp_axis_target_x -13338
#define temp_axis_target_y -13336

DECLARE_AXIS_WITH_DESC(flash_nlts_rpm_error_axis, NLTS_RPM_ERROR_AXIS_SIZE, "NLTS RPM Error",
                       "RPM") = {TEMP_AXIS_SRC_XDST, .size = NLTS_RPM_ERROR_AXIS_SIZE,
                                 .data = {
                                     // NLTS_X_TO_RPM_ERROR(-1000),
                                     NLTS_X_TO_RPM_ERROR(-500), NLTS_X_TO_RPM_ERROR(-375), NLTS_X_TO_RPM_ERROR(-250),
                                     NLTS_X_TO_RPM_ERROR(-125), NLTS_X_TO_RPM_ERROR(0), NLTS_X_TO_RPM_ERROR(125),
                                     NLTS_X_TO_RPM_ERROR(250), NLTS_X_TO_RPM_ERROR(375), NLTS_X_TO_RPM_ERROR(500),
                                     // NLTS_X_TO_RPM_ERROR(1000)
                                 }};

DECLARE_2DMAP16_WITH_DESC(flash_nlts_integral_torque_correction_2dmap16, NLTS_RPM_ERROR_AXIS_SIZE, "NLTS",
                          "Integral Torque Correction Step", "NLTSTorqueCorrection", "DXflash_nlts_rpm_error_axis") = {
    TEMP_2DMAP_SRC,
    .data = {
        // NLTS_X_TO_TORQUE_CORRECTION(10),
        NLTS_X_TO_TORQUE_CORRECTION(8), NLTS_X_TO_TORQUE_CORRECTION(4), NLTS_X_TO_TORQUE_CORRECTION(2),
        NLTS_X_TO_TORQUE_CORRECTION(1), NLTS_X_TO_TORQUE_CORRECTION(0), NLTS_X_TO_TORQUE_CORRECTION(0),
        NLTS_X_TO_TORQUE_CORRECTION(0), NLTS_X_TO_TORQUE_CORRECTION(-1), NLTS_X_TO_TORQUE_CORRECTION(-2),
        // NLTS_X_TO_TORQUE_CORRECTION(-4),
    }};

DECLARE_2DMAP16_WITH_DESC(flash_nlts_proportional_torque_correction_2dmap16, NLTS_RPM_ERROR_AXIS_SIZE, "NLTS",
                          "Proportional Torque Correction", "NLTSTorqueCorrection", "DXflash_nlts_rpm_error_axis") = {
    TEMP_2DMAP_SRC,
    .data = {
        // NLTS_X_TO_TORQUE_CORRECTION(500),
        NLTS_X_TO_TORQUE_CORRECTION(200), NLTS_X_TO_TORQUE_CORRECTION(80), NLTS_X_TO_TORQUE_CORRECTION(40),
        NLTS_X_TO_TORQUE_CORRECTION(20), NLTS_X_TO_TORQUE_CORRECTION(0), NLTS_X_TO_TORQUE_CORRECTION(-20),
        NLTS_X_TO_TORQUE_CORRECTION(-40), NLTS_X_TO_TORQUE_CORRECTION(-80), NLTS_X_TO_TORQUE_CORRECTION(-200),
        // NLTS_X_TO_TORQUE_CORRECTION(-500),
    }};

#define NLTS_ACTIVE_DECAY_AXIS_SIZE 5

DECLARE_AXIS_WITH_DESC(flash_nlts_active_decay_axis, NLTS_ACTIVE_DECAY_AXIS_SIZE, "NLTS Active Decay", "Time40Hz") = {
    TEMP_AXIS_SRC_XDST, .size = NLTS_ACTIVE_DECAY_AXIS_SIZE, .data = {0, 10, 20, 30, 40}};

DECLARE_2DMAP16_WITH_DESC(flash_nlts_partial_clutch_engagement_torque_limit_2dmap16, NLTS_ACTIVE_DECAY_AXIS_SIZE,
                          "NLTS", "Partial Clutch Engagement Torque Limit", "NLTSTorqueCorrection",
                          "DXflash_nlts_active_decay_axis") = {TEMP_2DMAP_SRC, .data = {
                                                                                   NLTS_X_TO_TORQUE_CORRECTION(700),
                                                                                   NLTS_X_TO_TORQUE_CORRECTION(650),
                                                                                   NLTS_X_TO_TORQUE_CORRECTION(600),
                                                                                   NLTS_X_TO_TORQUE_CORRECTION(550),
                                                                                   NLTS_X_TO_TORQUE_CORRECTION(500),
                                                                               }};
