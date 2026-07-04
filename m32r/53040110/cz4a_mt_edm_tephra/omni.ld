/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE ../../math.ld
INCLUDE description.ld
/*
nlts_rpm_error = 0x804572;
nlts_flags = 0x804574;
nlts_state = 0x804576;
nlts_target_rpm = 0x804578;


decays_x1_nlts_active = 0x804afe;

test_substitute_spark_advance_int_call_localtion = 0x32bec;


reset_tacho_call_location = 0x31a08;
*/
decays_x1_gear_unstable = 0x8080c8;
calculated_gear = 0x8087b0;
current_gear = 0x8087b1;
nlts_target_gear = 0x8087b8;

nlts_speed_filtered = 0x8087ca;
nlts_rpm_error = 0x8087cc;

nlts_flags = 0x8087a2;
nlts_target_rpm = 0x8087a4;
nlts_state = 0x8087a6;

overrev_spark_limit		= 0x808776;
overrev_cycle_decay		= 0x808778;
init_overrev_spark_limit	= 0x80877a;
overrev_spark_limit_dec_step	= 0x80877c;
revolution_limit		= 0x80877e;

decays_x1_nlts_active = 0x8080c6;

update_gpio_outputs = 0xb800;
update_gpio_outputs_call_location = 0x10b54;

fuel_cut_splice_into_location = 0x2cef4;
test_substitute_spark_advance_int_call_localtion = 0x2c810;

tacho_reset_call_location = 0x2b994;
tacho_reset = 0xc078;

update_accel_characteristic_limit_call_location = 0x11210;

MEMORY {
	UNUSED_MEMORY_FOR_MODS : ORIGIN = 0xa4000, LENGTH = 0x1000
}

SECTIONS {
	INCLUDE nlts_local.ld
	INCLUDE ../../gpio_outputs_hijack.ld

	"Omni#1" : {
		*(.text)
		*(.rodata)
	} > UNUSED_MEMORY_FOR_MODS

	"Hijack update_accel_characteristic_limit [m32r-bl]" update_accel_characteristic_limit_call_location : {
		LONG(new_update_accel_characteristic_limit)
	}

	"NewBoost#1 [m32r-bl]" 0x9e388 : { LONG(new_update_boost_target_load) }
	"NewBoost#2 [m32r-bl]" 0x9e38c : { LONG(new_calc_wastegate_reactive_duty) }

	"data_desc" 0xb0000 : {
		*(data_desc)
	}

	/* Spark cut tunable parameters -- placed in confirmed-free flash at 0xd5ff2.
	   EcuFlash edits these by address. */
	/* Replace sth r0,@(-13784,fp) inside update_coil_dwell_mappings.
	   Zeros coil_dwell_optimal_rpm_x_power when at/above cut RPM. */
	"Spark Cut [m32r-bl]" 0x217c8 : {
		LONG(new_coil_dwell_store)
	}

	"Spark Cut Divider" 0xd5ff2 : {
		flash_spark_cut_divider = .;
		BYTE(105)    /* 1.05x default: spark cut at fuel_cut_period x 1.05 */
	}
	"Spark Cut Stationary RPM" 0xd5ffa : {
		flash_spark_cut_stationary_rpm = .;
		SHORT(0x09c4) /* period limit when stationary */
	}
}
