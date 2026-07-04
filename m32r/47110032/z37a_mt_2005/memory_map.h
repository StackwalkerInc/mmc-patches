// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef MEMORY_MAP_H
#define MEMORY_MAP_H

#define dtc_mil_active_errors -16006

#define age_x1_ignition -14324

#define decays_x1_dash_symbol2_flasher -14216

#define decays_x1_mode_selector_active2 -14212
#define decays_x1_knock_mil_flash -14210
#define decays_x1_launch_control_active_actions -14208
#define decays_x1_gear_unstable -14206

#define decays_x1_gear_torque_insufficient -14184

#define decays_x1_canrx1_etacts_short -13902

#define decays_x1_canrx1_etacts_long -13882

#define decays_x1_mil_flash_timer -13726

#define decays_x4_closed_loop_afterstart_restriction -13514

#define temp_axis_src -13344

#define temp_axis_target_x -13338
#define temp_axis_target_y -13336

#define basic_ecu_load_axis_target -13332

#define gpio1 -13274

#define alt_inputs1_processed -13252
#define alt_inputs1_processed_prev -13250

#define alt_inputs2_processed -13236
#define alt_inputs2_processed_prev -13234

#define alt_inputs3_processed -13224
#define alt_inputs3_processed_prev -13222

#define coolant_temp -13206

#define tps_main_rcord -13140

#define adc_byte_mode -13112

#define engine_rpm -13060

#define engine_rpm_8kmax -13050

#define engine_rpm_avg1 -13044

#define launch_control_flags -13022
#define launch_common_rpm_error -13020
#define launch_control_cut_count -13018
#define launch_fuel_cut_rpm_error -13016
// #define launch_throttle_effectiveness -13018

#define map_engine_load -13008

#define launch_load_error -13002
#define current_gear -13000
#define calculated_gear -12999

#define gear_detector_gratio -12994

#define vehicle_speed -12922

#define vehicle_movement_decay -12918

#define mode_flags2 -12910

#define variant_coding1 -12906

#define mode_idx -12896

#define mode_selector_flags -12892

#define run_state_flags -12876

#define fp12850_f16 -12850

#define gear_ratio -12816

#define afr_correction_flags -12782

#define fuel_map_target_afr -12704

#define knock_sum -12354

#define boost_control_flags -12120
#define boost_target_load -12106

#define IS_CLUTCH_DEPRESSED (!IS_BIT_SET16(alt_inputs3_processed, GPINPUTS3_CLUTCH_PEDAL))

#define BRAKES_RELEASED                                                                                                \
	((readu16(alt_inputs2_processed_prev) ^ readu16(alt_inputs2_processed)) & readu16(alt_inputs2_processed_prev)      \
	 & GPINPUTS2_BRAKE_PEDAL)

#define ACCELERATOR_RELEASED                                                                                           \
	((readu16(alt_inputs1_processed_prev) ^ readu16(alt_inputs1_processed)) & readu16(alt_inputs1_processed)           \
	 & GPINPUTS1_ACCELERATOR_NEUTRAL)

#define sio0_diagnostic_session_is_or_was_active -11876

#define fp11872_u16 -11872
#define fp11870_u16 -11870
#define sio0_protocol_flags -11868

#define sio0_state -11818

#define engine_torque_output_with_losses -10450

#define can_rx_abs_speed_rear -9876

#define can_rx2_data01_u16 -9832
#define knock_mil_flags -9830
#define can_rx2_data234_u32 -9828
#define can_rx1_data0_u8 -9824
#define can_rx1_data3_u16 -9822
#define knock_mil_state -9820
#define can_rx0_data0_u16 -9818

#define can_vehicle_speed -9218

#define tomo_variant_coding1 -8898

#define low_gear_flags -7382

// not true "decays_x1" anymore but who cares
#define decays_x1_ignition -7376

#define dash_symbol -6248
#define dash_symbol2 -6247
#define dash_control_mode -6246
#define dash_symbol5 -6244

#define can_tx2_done_flags -6200

#endif /*MEMORY_MAP_H*/
