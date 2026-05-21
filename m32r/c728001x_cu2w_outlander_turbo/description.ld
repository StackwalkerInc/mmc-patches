/* SPDX-License-Identifier: GPL-3.0-or-later */
update_mil = 0x23d30;
update_mil_call_location = 0x22a14;

test_substitute_spark_advance_int_call_localtion = 0x26eb8;

update_gpio_outputs = 0xdd7c;
update_gpio_outputs_call_location = 0x13e60;

gpio1			= 0x804d30;
tps_main_rcord		= 0x804db0;
engine_rpm		= 0x804e00;
map_engine_load		= 0x804e2a;
knock_sum		= 0x805120;
ecu_load		= 0x804e24;
maf_sensor_flow		= 0x804e8a;
sensor_faults		= 0x804eae;
vehicle_movement_decay	= 0x804e9a;
run_state_flags		= 0x804ec4;
run_state_extended_flags	= 0x804f32;
shaft_period1_copy_dline0 = 0x805442;
alt_inputs3_processed	= 0x804d58;
gear_ratio		= 0x804f0e;
engine_rpm_delta_neg	= 0x804e04;

load_source_value = 0x804e54;


flash_mut_variables_table = 0x39bf4;


flash_maf_fault_revolution_period_limit = 0x17d2;
flash_revolution_period_limit		= 0x86a;

age_x1_ignition = 0x8048fc;
temp_axis_src	= 0x804cf6;

/* RAM and call-site symbols referenced by the shared sources but not
   hooked up on this ROM (the corresponding patch sections in mmc-research's
   omni.ld were commented out). PROVIDE safe stubs so the link resolves;
   the call sites stay stock. */
PROVIDE(decays_x1_mil_pulse_timer = 0x8049f0);
PROVIDE(decays_x1_alt_mode_change_cel_flash_timer = 0x804968);
PROVIDE(flash_alt_mode_change_cel_flash_time = 0);
PROVIDE(flash_alt_mode_change_cel_flash_time_slice = 0);
PROVIDE(fuel_cut_splice_into_location = 0);
PROVIDE(post_fuel_cut_enrichment = 0x804ed0);
PROVIDE(const128_nominal_ipw_multiplier_call_location = 0);
PROVIDE(tacho_reset_call_location = 0);
PROVIDE(tacho_reset = 0);
PROVIDE(reset_engine_rpm_state = 0);
PROVIDE(adc_run = 0);
PROVIDE(oneshot_crank_event_flags = 0x804ed0);
