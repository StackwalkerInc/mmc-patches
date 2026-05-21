// SPDX-License-Identifier: GPL-3.0-or-later
#include "fmath.h"
#include "stdint.h"
#include "gpio.h"
#include "memaccess.h"
#include "memory_map.h"

#include "launch_control.h"
#include "launch_control_data.h"

#define LAUNCH_CONTROL_RPM_AXIS_SIZE 9
#define LAUNCH_CONTROL_LOAD_ERROR_AXIS_SIZE 5

const uint8_t flash_launch_disable_asc_per_mode = 0x80;

DECLARE_AXIS(flash_launch_control_rpm_error_axis, LAUNCH_CONTROL_RPM_AXIS_SIZE) = {
    TEMP_AXIS_SRC_XDST, .size = LAUNCH_CONTROL_RPM_AXIS_SIZE, .data = {0, 32, 64, 96, 128, 160, 192, 224, 255}};

DECLARE_AXIS(flash_launch_control_load_error_axis, LAUNCH_CONTROL_LOAD_ERROR_AXIS_SIZE) = {
    TEMP_AXIS_SRC_YDST,
    .size = LAUNCH_CONTROL_LOAD_ERROR_AXIS_SIZE,
    .data = {0, 96, 128, 160, 256},
};

#define ECU_LOAD_BASIC_AXIS_SIZE 14

DECLARE_2DMAP8(flash_launch_control_fuel_cut_2dmap8,
               LAUNCH_CONTROL_RPM_AXIS_SIZE) = {.type = 2,
                                                .xsrc = MAP_AXIS_POINTER(temp_axis_target_x),
                                                .data = {
                                                    0,
                                                    0,
                                                    0,
                                                    1,
                                                    2,
                                                    3,
                                                    3,
                                                    4,
                                                    4,
                                                }};

DECLARE_2DMAP8(flash_launch_control_enrichment_force_2dmap8, LAUNCH_CONTROL_RPM_AXIS_SIZE) = {
    TEMP_2DMAP_SRC,
    .data = {0, 0, 20, 20, 26, 26, 30, 30, 30},
};

DECLARE_3DMAP8(flash_launch_control_spark_retard_force_3dmap8, LAUNCH_CONTROL_RPM_AXIS_SIZE,
               LAUNCH_CONTROL_LOAD_ERROR_AXIS_SIZE) = {TEMP_3DMAP_SRC, .xsize = LAUNCH_CONTROL_RPM_AXIS_SIZE,
                                                       .data = {
                                                           0,   0,   0,   255, 255, 255, 255, 255, 255, 0,   0,   0,
                                                           255, 255, 255, 255, 255, 255, 0,   0,   0,   255, 255, 255,
                                                           255, 255, 255, 0,   0,   0,   128, 128, 128, 128, 128, 128,
                                                           0,   0,   0,   128, 128, 128, 128, 128, 128,
                                                       }};

const uint16_t flash_init_launch_control_aftercut_closed_loop_delay = 4; // 2 seconds

// apps geared
#define launch_apps -10168
unsigned is_launch_fuel_cut(unsigned p_arg)
{
	if (!IS_BIT_SET16(launch_control_flags, LAUNCH_CONTROL_RPM_HOLD)) {
		writeu8(0, launch_control_cut_count);
		BIT_CLEAR16(launch_control_flags, LAUNCH_CONTROL_FUEL_CUT);
		return p_arg;
	}

	writeu16(readu16(launch_fuel_cut_rpm_error), temp_axis_src);
	calc_axis(&flash_launch_control_rpm_error_axis);

	uint_fast8_t l_count = map8u16(&flash_launch_control_fuel_cut_2dmap8);
	writeu8(l_count, launch_control_cut_count);
	if (l_count
	    && (readu16(decays_x4_closed_loop_afterstart_restriction)
	        < flash_init_launch_control_aftercut_closed_loop_delay)) {
		writeu16(flash_init_launch_control_aftercut_closed_loop_delay, decays_x4_closed_loop_afterstart_restriction);
	}

	// BIT_CONDITION16(launch_control_flags, LAUNCH_CONTROL_FUEL_CUT, readu16(engine_rpm) >
	// multiu16(flash_launch_engine_rpm_per_mode) + 128);
	return p_arg;
}

extern void update_fuel_map_target_afr();

static uint16_t get_launch_target_afr()
{
	switch (flash_launch_control_enrichment_mode) {
	case LC_ENRICHMENT_MODE_STATIC:
		return readu16(fuel_map_target_afr) + flash_launch_enrichment;
	case LC_ENRICHMENT_MODE_FORCE: {
		writeu16(readu16(launch_common_rpm_error), temp_axis_src);
		calc_axis(&flash_launch_control_rpm_error_axis);
		return readu16(fuel_map_target_afr) + map8u16(&flash_launch_control_enrichment_force_2dmap8);
	}
	default:
		return readu16(fuel_map_target_afr);
	}
}

void new_trampoline_update_fuel_map_target_afr()
{
	update_fuel_map_target_afr();
	if (IS_BIT_SET16(launch_control_flags, LAUNCH_CONTROL_FUEL_ENRICHMENT)) {
		writeu16(s_16to8(get_launch_target_afr()), fuel_map_target_afr);
	}
}

extern uint16_t scale_can_vehicle_speed(uint16_t p_speed, uint16_t p_meters_per_discrete);

ROM_SECTION("lcf_control") void update_launch_control_flags()
{
	if (!(flash_launch_on_per_mode & (1 << readu16(mode_idx)))) {
		writeu16(0, launch_control_flags);
		return;
	}
	HYSTERESIS_FLAG(launch_control_flags, LAUNCH_CONTROL_APPS_HIGH, tps_main_rcord, flash_launch_apps[1],
	                flash_launch_apps[0]);

	uint_fast16_t l_lcf = readu16(launch_control_flags);
	int l_refresh = 0;

	if (!(l_lcf & LAUNCH_CONTROL_APPS_HIGH)) {
		if (l_lcf & LAUNCH_CONTROL_ON) {
			pushi();
			BIT_CLEAR16(variant_coding1, 0x02);
			BIT_CLEAR16(tomo_variant_coding1, 0x02);
			popi();
		}
		l_lcf &= ~(LAUNCH_CONTROL_ON | LAUNCH_CONTROL_ACTIVE_ACTIONS | LAUNCH_CONTROL_FUEL_CUT);
	} else {
		if (!readu16(vehicle_movement_decay)
#ifdef AT_BUILD
		    && (flash_ignore_brake_pedal_for_launch || IS_BRAKES_DEPRESSED)
#else
		    && (flash_ignore_clutch_pedal_for_launch || IS_CLUTCH_DEPRESSED)
#endif
		) {
			if (readu16(launch_common_rpm_error) > 128)
				l_lcf |= LAUNCH_CONTROL_ON | LAUNCH_CONTROL_ACTIVE_ACTIONS;
			writeu16(flash_init_launch_control_active_actions_decay, decays_x1_launch_control_active_actions);
			l_refresh = 1;
		}

		if (readu16(vehicle_speed) > 15) { // 30kph
			if (l_lcf & LAUNCH_CONTROL_ON) {
				pushi();
				BIT_CLEAR16(variant_coding1, 0x02);
				BIT_CLEAR16(tomo_variant_coding1, 0x02);
				popi();
			}
			l_lcf &= ~LAUNCH_CONTROL_ON;
		}
		if (flash_launch_disable_asc_per_mode & (1 << readu16(mode_idx))) {
			if (l_lcf & LAUNCH_CONTROL_ON) {
				pushi();
				BIT_SET16(variant_coding1, 0x02);
				BIT_SET16(tomo_variant_coding1, 0x02);
				popi();
			} else {
				pushi();
				BIT_CLEAR16(variant_coding1, 0x02);
				BIT_CLEAR16(tomo_variant_coding1, 0x02);
				popi();
			}
		}
	}
	if (flash_launch_binary_mode && !l_refresh)
		writeu16(0, decays_x1_launch_control_active_actions);
	uint16_t l_active_actions_time_left = readu16(decays_x1_launch_control_active_actions);
	if (l_active_actions_time_left < flash_active_actions_rpm_hold_release_threshold) {
		l_lcf &= ~LAUNCH_CONTROL_RPM_HOLD;
	}
	if (l_active_actions_time_left < flash_active_actions_fuel_enrichment_release_threshold) {
		l_lcf &= ~LAUNCH_CONTROL_FUEL_ENRICHMENT;
	}
	if (l_active_actions_time_left < flash_active_actions_spark_limit_release_threshold) {
		l_lcf &= ~LAUNCH_CONTROL_SPARK_LIMIT;
	}
	if (!l_active_actions_time_left) {
		l_lcf &= ~LAUNCH_CONTROL_ACTIVE_ACTIONS;
	}
	writeu16(l_lcf, launch_control_flags);
}

void update_launch_errors()
{
	writeu16(s_16to8(s_sub16(readu16(engine_rpm) + 128, multiu16(flash_launch_engine_rpm_per_mode))),
	         launch_common_rpm_error);
	writeu16(s_16to8(s_sub16(readu16(map_engine_load) + 128, flash_launch_target_load)), launch_load_error);
	if (flash_launch_control_fuel_cut_use_averaged_engine_speed) {
		writeu16(s_16to8(s_sub16(((readu16(engine_rpm_avg1) / 8) + 1) / 2 + 128,
		                         multiu16(flash_launch_engine_rpm_per_mode))),
		         launch_fuel_cut_rpm_error);
	} else {
		writeu16(readu16(launch_common_rpm_error), launch_fuel_cut_rpm_error);
	}
}

uint16_t update_launch_control_spark_limit(uint16_t p_spark)
{
	update_launch_errors();
	update_launch_control_flags();

	if (!IS_BIT_SET16(launch_control_flags, LAUNCH_CONTROL_ON)) {
		return p_spark;
	}

	if (!IS_BIT_SET16(launch_control_flags, LAUNCH_CONTROL_SPARK_LIMIT)) {
		return p_spark;
	}
	uint16_t l_spark_limit = p_spark;
	switch (flash_launch_control_spark_limit_mode) {
	case LC_SPARK_LIMIT_MODE_STATIC:
		l_spark_limit = multiu16(flash_launch_spark_max_per_mode);
		break;
	case LC_SPARK_LIMIT_MODE_RETARD_FORCE:
		writeu16(readu16(launch_common_rpm_error), temp_axis_src);
		calc_axis(&flash_launch_control_rpm_error_axis);

		writeu16(readu16(launch_load_error), temp_axis_src);
		calc_axis(&flash_launch_control_load_error_axis);

		l_spark_limit = aprxu16_255(multiu16(flash_launch_spark_max_per_mode), p_spark,
		                            map8u16(&flash_launch_control_spark_retard_force_3dmap8));
		break;
	}

	return MIN16(p_spark, l_spark_limit);
}
