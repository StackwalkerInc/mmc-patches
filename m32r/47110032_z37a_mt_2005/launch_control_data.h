// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef LAUNCH_CONTROL_DATA_H
#define LAUNCH_CONTROL_DATA_H

#include "stdint.h"

extern const uint8_t flash_launch_on_per_mode;

#define LC_ENRICHMENT_MODE_STATIC 0
#define LC_ENRICHMENT_MODE_FORCE 1
#define LC_ENRICHMENT_MODE_3DMAP 2
extern const uint8_t flash_launch_control_enrichment_mode;
#define LC_SPARK_LIMIT_MODE_STATIC 0
#define LC_SPARK_LIMIT_MODE_RETARD_FORCE 1
#define LC_SPARK_LIMIT_MODE_3DMAP 2
extern const uint8_t flash_launch_control_spark_limit_mode;
extern const uint16_t flash_launch_apps[];
extern const uint16_t flash_launch_engine_rpm_per_mode[8];
extern const uint16_t flash_launch_spark_max_per_mode[8];
extern const uint16_t flash_launch_enrichment;

extern const uint16_t flash_launch_target_load;

extern const uint8_t flash_ignore_brake_pedal_for_launch;
extern const uint8_t flash_ignore_clutch_pedal_for_launch;
extern const uint8_t flash_launch_binary_mode;
extern const uint8_t flash_launch_control_fuel_cut_use_averaged_engine_speed;
extern const uint16_t flash_init_launch_control_active_actions_decay;
extern const uint16_t flash_active_actions_rpm_hold_release_threshold;
extern const uint16_t flash_active_actions_fuel_enrichment_release_threshold;
extern const uint16_t flash_active_actions_spark_limit_release_threshold;

#endif /*LAUNCH_CONTROL_DATA_H*/
