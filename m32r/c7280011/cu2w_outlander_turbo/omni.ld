/* SPDX-License-Identifier: GPL-3.0-or-later */
decays_x1_knock_mil_flash = 0x8049de;
/*decays_x1_mil_flash_timer = 0x804b66;*/
decays_x1_mil_flash_timer = 0x8049f0;
knock_mil_state = 0x804e34;
knock_mil_flags = 0x804e32;
overrev_cycle_decay = 0x804e36;
revolution_limit = 0x804e38;
nlts_state	= 0x804e3a;
nlts_flags	= 0x804e3c;
nlts_target_rpm	= 0x804e3e;
nlts_rpm_error	= 0x804e40;
overrev_spark_limit = 0x804e42;
init_overrev_spark_limit = 0x804e44;
overrev_spark_limit_dec_step = 0x804e46;

decays_x1_nlts_active = 0x8049e4;

load1byte = 0x804e2c;

INCLUDE description.ld
INCLUDE ../../math.ld

MEMORY {
	UNUSED_MEMORY_FOR_MODS : ORIGIN = 0x56130, LENGTH =0x1000
}

SECTIONS {
	"Update ROMID" 0x224 : { BYTE(0xa3) }

	"CommonCode#0" : {
		*(.text)
		*(.rodata)
	} > UNUSED_MEMORY_FOR_MODS

	"Nopout CRC check" 0xef20 : {
		SHORT(0x7000)
		SHORT(0x7000)
	}

	"data_desc" 0x60000 : {
		*(data_desc)
	}

/*
	"Fuel cut for nlts/launch [m32r-ld24-r4]" 0x276e4 : {
		LONG(revolution_limit)
	}
*/
/*
	"Fuel cut for nlts/launch [m32r-splice-into-function]" 0x276d0 : {
		LONG(update_run_state_extended_flags_overrev)
		LONG(0x27714)
	}
	"Post fuel cut spark limit [m32r-bl]" test_substitute_spark_advance_int_call_localtion : { LONG(new_test_substitute_spark_advance_int) }

	INCLUDE ../../knockcel_injection.ld
	INCLUDE ../../gpio_outputs_hijack.ld

	"data_desc" 0x60000 : {
		*(data_desc)
	}

	"Load2Byte,RPM2Byte,Airflow2Byte" flash_mut_variables_table : {
		LONG(ecu_load)
		LONG(ecu_load + 1)
		LONG(engine_rpm)
		LONG(engine_rpm + 1)
		LONG(maf_sensor_flow)
		LONG(maf_sensor_flow + 1)
	}
	"Replace nil with Load1Byte in MUT_B6: x*5/4 %" flash_mut_variables_table + 0xb6 * 4 : { LONG(load1byte) }
	"Place gear_ratio to MUTA2-A3" flash_mut_variables_table + 0xa2 * 4 : {
		LONG(gear_ratio)
		LONG(gear_ratio + 1)
	}
	"Place nlts_flags to MUTA4" flash_mut_variables_table + 0xa4 * 4 : {
		LONG(nlts_flags + 1)
	}
*/
}
