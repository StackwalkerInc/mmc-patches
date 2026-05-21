// SPDX-License-Identifier: GPL-3.0-or-later
#include "launch_control_data.h"

const uint8_t flash_launch_on_per_mode = 0xfe;

const uint8_t flash_launch_control_enrichment_mode = 0;
const uint8_t flash_launch_control_spark_limit_mode = 1;
const uint16_t flash_launch_apps[] = {110, 120};

const uint16_t flash_launch_engine_rpm_per_mode[8] = {
    2.5 * 256, 2.5 * 256, 3.0 * 256, 3.5 * 256,

    4.0 * 256, 4.0 * 256, 4.5 * 256, 4.5 * 256,
};

const uint16_t flash_launch_spark_max_per_mode[8] = {15, 15, 15, 15, 15, 10, 15, 10};

const uint16_t flash_launch_enrichment = 26;

const uint16_t flash_launch_target_load = 640 * 3 / 4;

const uint8_t flash_ignore_brake_pedal_for_launch = 0;
const uint8_t flash_ignore_clutch_pedal_for_launch = 0;
const uint8_t flash_launch_binary_mode = 1;
const uint8_t flash_launch_control_fuel_cut_use_averaged_engine_speed = 1;
const uint16_t flash_init_launch_control_active_actions_decay = 120;
const uint16_t flash_active_actions_rpm_hold_release_threshold = 80;
const uint16_t flash_active_actions_fuel_enrichment_release_threshold = 0;
const uint16_t flash_active_actions_spark_limit_release_threshold = 60;
