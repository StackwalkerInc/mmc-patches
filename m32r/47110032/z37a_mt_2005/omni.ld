/* SPDX-License-Identifier: GPL-3.0-or-later */

pushi = 0x3910;
popi = 0x3928;

mut_table_start = 0x3f484;
scale_can_vehicle_speed = 0x14420;

/* used for can topcall replacement*/
can0_update_bus_state = 0x2ba80;
can0_update_tx_data = 0x2c2e0;

/*knock mil*/
flash_mil_ignition_enable_age_max = 0x51740;

/*for dash display can tx*/
flash_can_tx2_done_index = 0x9524;
flash_can_tx2_done_mask = 0x952b;
can_tx2_request = 0x41820;

s_add16 = 0x7600;
s_add32 = 0x7620;
s_16to8 = 0x7694;
s_32to16 = 0x76a8;
mid16 = 0x76b8;
s_sub16 = 0x7f80;
s_sub32 = 0x7f98;
s16_divu32_16 = 0x79e8;
map8u16	 = 0x4e664;
mapu16 = 0x4e734;
calc_axis = 0x4e8cc;
multimap8u16 = 0x4e7ec;
multiu8 = 0x4e83c;
multiu16 = 0x4e84c;
aprxu16_255 = 0x7b54;

flash_overheat_protection_rpm_min = 0x5136c;
flash_overheat_protection_coolant_temp_on = 0x5136e;
flash_overheat_protection_coolant_temp_off = 0x51370;
flash_boost_target_load_offset = 0x51770;

/*etacs extension*/
flash_can_rx_handlers_1 = 0x9598;
flash52530_u16 = 0x52530;
flash526d6_u16 = 0x526d6;

update_fuel_map_target_afr = 0x176a8;

update_boost_target_load = 0x1fc04;
flash_boost_control_3d_rpm_axis = 0x4f888;
flash_boost_control_3d_tps_axis = 0x4f838;
flash_boost_control_target_load_high_gear_3dmap8_stock = 0x55df2;
flash_boost_control_target_load_low_gear_3dmap8_stock = 0x55e54;

opcode_bl_to_trampoline_update_fuel_map_target_afr = 0x17288;
opcode_bl_to_adc_convert_mode = 0x10aa0;
opcode_bl_to_can_topcall = 0x4e1bc;

opcode_bl_to_is_overheat_protection_enrichment_enabled = 0x175dc;
opcode_bl_to_nop15ab4 = 0x15a9c;

nlts_speed		= 0x804df2;
nlts_speed_filtered	= 0x804df4;
nlts_flags		= 0x804df6;
nlts_target_gear	= 0x804df8;
nlts_state		= 0x804df9;
nlts_target_rpm		= 0x804dfa;

nlts_torque_limit		= 0x804dfe;
nlts_integral_torque_correction = 0x804e00;

nlts_rpm_error		= 0x804e48;

decays_x1_nlts_active	= 0x80489e;

canrx_rear_axle_speed	= 0x80596c;
engine_rpm		= 0x804cfc;
engine_rpm_delta_neg	= 0x804d00;
accel_pedal_position_scaled_corrected_smoothed = 0x8057bc;
alt_inputs3_processed = 0x804c58;
temp_axis_src = 0x804be0;

get_target_torque_output_limit_nm = 0x14388;
get_target_torque_output_limit_nm_call_location = 0x13b68;
cruise_control = 0x4e1f0;
cruise_control_call_location = 0x4e174;
scale_can_vehicle_speed = 0x14420;

current_gear = 0x804d38;
calculated_gear = 0x804d39;
torque_request_flags = 0x80585e;
cantx_torque_min_nm = 0x80587c;

shift_light_state = 0x804cf0;

shaft_period1_copy_dline0 = 0x8052b2;
flash_revolution_period_limit = 0x51216;
run_state_extended_flags = 0x804e0e;

revolution_limit = 0x804cf2;
overrev_cycle_decay = 0x804cf4;

/*[3c730,3cd30), [46738,46e68) is available for scavenging*/
MEMORY {
	IDLE_CHECK : ORIGIN = 0x3c730, LENGTH = 0x600
	MDP_EVAP_EXT_CHECK : ORIGIN = 0x46738, LENGTH = 0x730
	LAST_UNUSED_FLASH : ORIGIN = 0x5fc74, LENGTH = 0x38a
	MIDDLE_UNUSED_FLASH : ORIGIN = 0x4fcbc, LENGTH = 0x344
	UPDATE_MIL_FLASH : ORIGIN = 0x215f0, LENGTH = 0x358
	MD_CONTROL_IN_CALC_IPW : ORIGIN = 0x25a80, LENGTH = 0x50
	UNUSED_RODATA_FLASH : ORIGIN = 0x4fcc0, LENGTH = 0x340
	UNUSED_UPDATE_FUEL_LEVEL : ORIGIN = 0x12c58, LENGTH = 0xac
}
SECTIONS {
	"ReplaceROMID" 0x50022 : { LONG(0x4711a032) }

	"Replace update_mil with knock_conditional" : {
		*(update_mil_section)
		*(knock_mil_condition_section)
		*(knock_mil_data_section)
	} > UPDATE_MIL_FLASH
	"hide Rcmod from stock with nops" 0x33c80 : {
		SHORT(0x7000)
		SHORT(0x7000)
	}
	"NLTS Code" : {
		*(lcf_control)
		gear_detector.o(*)
	} > LAST_UNUSED_FLASH

	"Rcmod launch control lcf code" : {
		nlts3.o(*)
	} > MDP_EVAP_EXT_CHECK
	"Rcmod common code" : {
/*
		dash_display.o(*)
		mode_selector.o(*)
*/
		*(.text)
	} > IDLE_CHECK


	"Launchmd" : {
		*(md_replacetext)
	} > MD_CONTROL_IN_CALC_IPW
/*
	"Rcmod common code" : {
		*(.text)
	} > MDP_EVAP_EXT_CHECK
*/
	"Rcmod common rodata" : {
		nlts2_data.o(*)
		*(.rodata)
	} > MIDDLE_UNUSED_FLASH
	. = 0x80d000;
	.data : { *(.data) }

	"Replace stock update_boost_target_load with multimapped" update_boost_target_load : { *(boost_target_load) }
	"Replace stock can_rx_etacs_handler1 with extended for position lights" flash_can_rx_handlers_1 : { LONG(can_rx_etacs_extended_handler) }
	"Inject launch spark correction instead of former als" 0x1a980 : { LONG(update_launch_control_spark_limit) }
	"Inject new update_low_gear_flags_and_apps_limit()" 0x109f0 : { LONG(update_low_gear_flags_and_apps_limit) }

	"UseModeIdxTable" 0x50012 : { SHORT(0x0001) }
	"ModeIdxTableContents" 0x5002a : {
		SHORT(0x0000)
		SHORT(0x0001)
		SHORT(0x0002)
		SHORT(0x0003)
		SHORT(0x0004)
		SHORT(0x0005)
		SHORT(0x0006)
		SHORT(0x0007)
	}
	"Inject launch correct fuel_map_target_afr calculation" opcode_bl_to_trampoline_update_fuel_map_target_afr : { LONG(new_trampoline_update_fuel_map_target_afr) }
	"Inject launch fuel cut" opcode_bl_to_nop15ab4 : { LONG(is_launch_fuel_cut) }

	"Inject ModeSelector" opcode_bl_to_adc_convert_mode : { LONG(update_mode_selector) }
	"Inject CAN_Topcall for DashDisplay" opcode_bl_to_can_topcall : { LONG(can_topcall_replacement) }
	"Inject hijack_cruise_to_update_nlts_target_torque_limit" cruise_control_call_location : { LONG(hijack_cruise_to_update_nlts_target_torque_limit) }
	"Inject hijack_target_torque_output_limit_nm" get_target_torque_output_limit_nm_call_location : { LONG(hijack_target_torque_output_limit_nm) }
/*
	"Inject hijack_speed_speed_limit" 0x15728 : { LONG(is_nlts_fuel_cut) }
*/

	"Inject new revolution limit" 0x2523c : {
		LONG(update_run_state_extended_flags_overrev)
	}
	"Nopout stock overret" 0x25240 : {
		SHORT(0x7000)
		SHORT(0x7000)
		SHORT(0x7000)
		SHORT(0x7000)

		SHORT(0x7000)
		SHORT(0x7000)
		SHORT(0x7000)
		SHORT(0x7000)

		SHORT(0x7000)
		SHORT(0x7000)
		SHORT(0x7000)
		SHORT(0x7000)

		SHORT(0x7000)
		SHORT(0x7000)
		SHORT(0x7000)
		SHORT(0x7000)

		SHORT(0x7000)
		SHORT(0x7000)
		SHORT(0x7000)
		SHORT(0x7000)
	}

	"Inject new_test_substitute_spark_advance_int" 0x24d10 : {
		LONG(new_test_substitute_spark_advance_int)
	}

}
