// SPDX-License-Identifier: GPL-3.0-or-later
#include "nlts2_data.h"
#include "stdint.h"
#include "fmath.h"
#include "gpio.h"

#include "gear_detector_data.h"
#include "torque_request_flags.h"

extern void *const flash_nlts_rpm_error_axis;
extern void *const flash_nlts_active_decay_axis;
extern void *const flash_nlts_integral_torque_correction_2dmap16;
extern void *const flash_nlts_proportional_torque_correction_2dmap16;
extern void *const flash_nlts_partial_clutch_engagement_torque_limit_2dmap16;

extern uint16_t canrx_rear_axle_speed;
extern uint16_t engine_rpm;
extern uint16_t engine_rpm_delta_neg;
extern uint16_t accel_pedal_position_scaled_corrected_smoothed;
extern uint16_t alt_inputs3_processed;
extern uint16_t temp_axis_src;
extern uint16_t torque_request_flags;
extern uint16_t cantx_torque_min_nm;

#define NLTS_USE_ABS_REAR_AXLE_SPEED

uint16_t scale_can_vehicle_speed(uint16_t p_speed, uint16_t p_meters_per_discrete);

static void update_nlts_vehicle_speed()
{
#if defined(NLTS_USE_ABS_REAR_AXLE_SPEED)
	nlts_speed = scale_can_vehicle_speed(canrx_rear_axle_speed, 250);
#elif defined(NLTS_USE_ABS_FRONT_AXLE_SPEED)
	nlts_speed = canrx_front_axle_speed;
#else
	nlts_speed = s_32to16(vehicle_speed * 256);
#endif

	nlts_speed_filtered = aprxu16_255(nlts_speed_filtered, nlts_speed, flash_nlts_speed_averaging_rate);
}

static uint16_t get_gear_engine_rpm(unsigned p_gear)
{
	return s16_divu32_16(nlts_speed_filtered << 16, flash_nlts_gear_ratios[p_gear]);
}

#define MAX(_x, _y)                                                                                                    \
	({                                                                                                                 \
		unsigned x = (_x);                                                                                             \
		unsigned y = (_y);                                                                                             \
		x < y ? y : x;                                                                                                 \
	})

#define HYSTERESIS_FLAG(flag_var, _bit_mask, condition_var, conditions)                                                \
	do {                                                                                                               \
		uint_fast16_t var = flag_var;                                                                                  \
		const uint_fast16_t bit_mask = _bit_mask;                                                                      \
		uint_fast16_t covar = condition_var;                                                                           \
		if (var & bit_mask) {                                                                                          \
			if (conditions[0] >= covar)                                                                                \
				flag_var = var & ~bit_mask;                                                                            \
		} else {                                                                                                       \
			if (conditions[1] < covar)                                                                                 \
				flag_var = var | bit_mask;                                                                             \
		}                                                                                                              \
	} while (0)

static uint8_t get_nlts_target_gear()
{
	if (!(nlts_flags & NLTS_FLAGS_APPS_HIGH))
		return 0;
	if (!(nlts_flags & NLTS_FLAGS_CURRENT_GEAR_CORRECT))
		return 0;
	if (nlts_flags & NLTS_FLAGS_GEAR_DOWN_RPM)
		return MAX(1, calculated_gear - 1);

	return MIN(flash_nlts_gear_max, calculated_gear + 1);
}

static uint_fast16_t s_torque_correct(uint_fast16_t l, uint_fast16_t r)
{
	return s_32to16(s_sub32(s_add32(l, r), NLTS_NEUTRAL_TORQUE));
}

static uint_fast16_t s_torque_div(uint_fast16_t l, uint_fast16_t r)
{
	if (!r)
		return l;
	if (l >= NLTS_NEUTRAL_TORQUE) {
		return NLTS_NEUTRAL_TORQUE + (l - NLTS_NEUTRAL_TORQUE) / r;
	} else {
		return NLTS_NEUTRAL_TORQUE - (NLTS_NEUTRAL_TORQUE - l) / r;
	}
}

#undef IS_CLUTCH_DEPRESSED
#define IS_CLUTCH_DEPRESSED (!(alt_inputs3_processed & GPINPUTS3_CLUTCH_PEDAL))

#define BIT_SET_CONDITION(var, bit_mask, condition)                                                                    \
	do {                                                                                                               \
		if (condition) {                                                                                               \
			var |= bit_mask;                                                                                           \
		} else {                                                                                                       \
			var &= ~(bit_mask);                                                                                        \
		}                                                                                                              \
	} while (0)

#define IS_BIT_SWITCHON(old_var, var, bit_mask) ((old_var ^ var) & var & (bit_mask))

const uint16_t flash_nlts_fuel_cut_rpm_error_thresholds[2] = {32768 + 1, 32768 + 2};

static void update_nlts_flags()
{
	HYSTERESIS_FLAG(nlts_flags, NLTS_FLAGS_APPS_HIGH, accel_pedal_position_scaled_corrected_smoothed,
	                flash_nlts_app_thresholds);
	BIT_SET_CONDITION(nlts_flags, NLTS_FLAGS_CLUTCH_DEPRESSED, IS_CLUTCH_DEPRESSED);
	BIT_SET_CONDITION(nlts_flags, NLTS_FLAGS_GEAR_DOWN_RPM, engine_rpm < flash_nlts_gear_down_rpm_max);
	BIT_SET_CONDITION(nlts_flags, NLTS_FLAGS_CURRENT_GEAR_CORRECT, calculated_gear != 0);
	BIT_SET_CONDITION(
	    nlts_flags, NLTS_FLAGS_CLUTCH_PARTIAL_ENGAGEMENT,
	    (nlts_state == NLTS_STATE_ON)
	        && ((nlts_flags & NLTS_FLAGS_CLUTCH_PARTIAL_ENGAGEMENT)
	            || (decays_x1_nlts_active < s_sub16(flash_init_nlts_active_decay, flash_nlts_delta_holdoff))
	                   && (engine_rpm_delta_neg > flash_nlts_rpm_delta_threshold)));
}

void update_nlts_target_torque_limit()
{
	uint_fast16_t l_old_nlts_flags = nlts_flags;
	update_nlts_vehicle_speed();
	update_nlts_flags();
	if (IS_BIT_SWITCHON(l_old_nlts_flags, nlts_flags, NLTS_FLAGS_CLUTCH_DEPRESSED)) {
		nlts_target_gear = get_nlts_target_gear();
		if (nlts_target_gear) {
			nlts_state = NLTS_STATE_ON;
			decays_x1_nlts_active = flash_init_nlts_active_decay;
		} else {
			nlts_state = NLTS_STATE_UNLIMITED;
		}
	} else if (IS_BIT_SWITCHON(nlts_flags, l_old_nlts_flags, NLTS_FLAGS_CLUTCH_DEPRESSED)) {
		nlts_state = NLTS_STATE_OFF;
	}
	if ((nlts_state == NLTS_STATE_ON) && !decays_x1_nlts_active) {
		nlts_state = NLTS_STATE_UNLIMITED;
	}
	if ((nlts_state == NLTS_STATE_ON) && !(nlts_flags & NLTS_FLAGS_APPS_HIGH)) {
		nlts_state = NLTS_STATE_UNLIMITED;
	}
	if (nlts_state != NLTS_STATE_ON) {
		decays_x1_nlts_active = 0;
		nlts_target_gear = 0;
		nlts_target_rpm = engine_rpm;
		nlts_rpm_error = 32768;
		nlts_torque_limit = 0xffff;
		nlts_integral_torque_correction = NLTS_NEUTRAL_TORQUE;
		nlts_flags &= ~NLTS_FLAGS_FUEL_CUT;
		return;
	}

	if (IS_BIT_SWITCHON(l_old_nlts_flags, nlts_flags, NLTS_FLAGS_CLUTCH_PARTIAL_ENGAGEMENT)) {
		decays_x1_nlts_active = flash_init_nlts_active_decay_partial_engagement;
	}

	if (nlts_flags & NLTS_FLAGS_CLUTCH_PARTIAL_ENGAGEMENT) {
		nlts_target_rpm = engine_rpm;
		nlts_rpm_error = 32768;
		temp_axis_src = decays_x1_nlts_active;
		calc_axis(&flash_nlts_active_decay_axis);
		nlts_integral_torque_correction = NLTS_NEUTRAL_TORQUE;
		nlts_torque_limit =
		    s_sub16(mapu16(&flash_nlts_partial_clutch_engagement_torque_limit_2dmap16), NLTS_NEUTRAL_TORQUE - 2000);
		nlts_flags &= ~NLTS_FLAGS_FUEL_CUT;
	} else {

		nlts_target_rpm = s_add16(get_gear_engine_rpm(nlts_target_gear), flash_nlts_rpm_overshoot);
		nlts_rpm_error = s_32to16(s_sub32(engine_rpm + 32768, nlts_target_rpm));
		HYSTERESIS_FLAG(nlts_flags, NLTS_FLAGS_FUEL_CUT, nlts_rpm_error, flash_nlts_fuel_cut_rpm_error_thresholds);
		temp_axis_src = nlts_rpm_error;
		calc_axis(&flash_nlts_rpm_error_axis);

		uint_fast16_t l_icorr = mid16(
		    s_torque_correct(nlts_integral_torque_correction, mapu16(&flash_nlts_integral_torque_correction_2dmap16)),
		    flash_nlts_integral_torque_correction_limits[0], flash_nlts_integral_torque_correction_limits[1]);

		uint_fast16_t l_torque_limit =
		    s_sub16(s_torque_correct(
		                s_torque_div(nlts_integral_torque_correction, multiu8(flash_nlts_integral_divisor_multiu8a)),
		                s_torque_div(mapu16(&flash_nlts_proportional_torque_correction_2dmap16),
		                             multiu8(flash_nlts_proportional_divisor_multiu8a))),
		            NLTS_NEUTRAL_TORQUE - 2000);

		static const uint16_t flash_torque_correction_offset_mutiu16a[8] = {
		    600, 600, 500, 400, 300, 200, 100, 0,
		};

		l_torque_limit = s_add16(l_torque_limit, multiu16(flash_torque_correction_offset_mutiu16a));

		if (l_torque_limit < cantx_torque_min_nm) {
			l_icorr =
			    MIN(l_icorr + (cantx_torque_min_nm - l_torque_limit) * multiu8(flash_nlts_integral_divisor_multiu8a),
			        NLTS_NEUTRAL_TORQUE);
			// l_torque_limit = cantx_torque_min_nm;
		}

		nlts_integral_torque_correction = l_icorr;
		nlts_torque_limit = l_torque_limit;
	}
}

extern uint16_t get_target_torque_output_limit_nm();
extern void cruise_control();

extern uint16_t revolution_limit;
extern uint16_t overrev_cycle_decay;
extern const uint16_t flash_revolution_period_limit;

void hijack_cruise_to_update_nlts_target_torque_limit()
{
	cruise_control();
	update_nlts_target_torque_limit();
	if (nlts_flags & NLTS_FLAGS_FUEL_CUT) {
		revolution_limit = s16_divu32_16(1920000, nlts_target_rpm);
	} else {
		revolution_limit = flash_revolution_period_limit;
	}
}

uint16_t hijack_target_torque_output_limit_nm()
{
	uint16_t l_original = get_target_torque_output_limit_nm();
	if ((torque_request_flags & (TORQUE_REQUEST_FLAGS_CAN_ASC_LOW_LIMIT | TORQUE_REQUEST_FLAGS_CAN_ASC_HIGH_LIMIT))
	    || (nlts_torque_limit == 0xffff))
		return l_original;
	torque_request_flags |= TORQUE_REQUEST_FLAGS_CAN_ASC_HIGH_LIMIT | TORQUE_REQUEST_FLAGS_USE_SPARK_RETARD;
	return nlts_torque_limit;
}

#if 0
uint16_t is_nlts_fuel_cut()
{
	return nlts_flags & NLTS_FLAGS_FUEL_CUT ? 1 : 0;
}
#endif

static const uint16_t flash_init_overrev_cycle_decay = 4;
extern uint16_t shaft_period1_copy_dline0;
extern uint16_t run_state_extended_flags;

void update_run_state_extended_flags_overrev()
{
	if (shaft_period1_copy_dline0 < revolution_limit) {
		run_state_extended_flags |= 0x20;
		overrev_cycle_decay = flash_init_overrev_cycle_decay;
	} else {
		run_state_extended_flags &= ~0x20;
		unsigned l_decay = overrev_cycle_decay;
		if (l_decay)
			overrev_cycle_decay = l_decay - 1;
	}
}

uint16_t flash_spark_overrev_protection_limit = 0xe7;

uint16_t new_test_substitute_spark_advance_int(uint16_t p0)
{
	return overrev_cycle_decay ? MAX(p0, flash_spark_overrev_protection_limit) : p0;
}
