/* SPDX-License-Identifier: GPL-3.0-or-later */
alt_inputs3_processed = 0x80860e;
temp_axis_src = 0x808588;
vehicle_speed = 0x8087de;
run_state_extended_flags = 0x80887a;
engine_rpm = 0x80873e;

knock_sum = 0x808a42;

age_x1_ignition = 0x808010;
shaft_period1_copy_dline0 = 0x808d6e;
tps_main_rcord = 0x8086f2;
sensor_faults = 0x8087f8;
vehicle_movement_decay = 0x8087e2;
engine_rpm_delta_neg = 0x808742;
oneshot_crank_event_flags = 0x808810;
can_vehicle_speed = 0x809abe;

run_state_flags = 0x808814;

accel_characteristic_limit = 0x80a2d4;

flash_boost_control_rpm_axis = 0x625c6;
flash_boost_control_tps_axis = 0x62648;

tephra_flags = 0x805000;

boost_target_load = 0x808b52;
tps_target = 0x8086f2;
tps_target_correction = 0x804510;
map_engine_load = 0x80876c;

wastegate_base_duty = 0x80a91a;
wastegate_base_duty_for_correction = 0x808b4e;
mut_actuator_tests0 = 0x808c3a;

iat = 0x808650;

/* x16-scaled coil dwell cap written by update_coil_dwell_mappings at 0x217c8.
   fp-13784 = 0x80c000 - 13784 = 0x808a28. */
coil_dwell_optimal_rpm_x_power = 0x808a28;

/* `update_post_fuel_cut_enrichment` in revolution_limit.c references this
   RAM byte but its `Post fuel cut enrichment` hook is not wired up on
   this ROM (see nlts_local.ld). PROVIDE a safe stub so the link
   resolves; the code path is dead. */
PROVIDE(post_fuel_cut_enrichment = 0x808000);
