/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE ../m32170.ld
INCLUDE ../math.ld
INCLUDE description.ld

post_fuel_cut_enrichment = 0x805012;

decays_x1_gear_unstable = 0x804966;

calculated_gear = 0x805088;
current_gear = 0x805089;
dash_flash_runner = 0x80508a;
asc_change_lamp = 0x80508e;
asc_off = 0x80508f;
asc_off_prev = 0x805090;
shift_light_pattern = 0x805091;
cvt_dash_data0 = 0x805092;
cvt_dash_data1 = 0x805093;

decays_x1_alt_mode_change_cel_flash_timer = 0x804968;

/*
decays_x1_knock_mil_flash = 0x8049de;
decays_x1_mil_pulse_timer = 0x8049f0;
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
*/

/*load400 bindings*/
calc_ipw_override_shaft_multiplication_location = 0x3321c;
calc_ipw_override_load_x_nominal_ipw_division_location = 0x339b6;
calc_engine_loads_override_lsv_to_load_multiplier1_location = 0x1e255;
calc_engine_loads_override_lsv_to_load_multiplier2_location = 0x1e273;
calc_engine_loads_override_lsv_to_comp_load_multiplier_location = 0x1e28e;
tomo_calc_engine_loads_override_lsv_to_load_multiplier_location = 0x64d3d;
tomo_calc_engine_loads_override_lsv_to_flow_multiplier_location = 0x64d8e;
divide_by2_maf_charge_max_base_vs_rpm_2dmap16_location = 0x6222;
flash_base_spark_limit_reset_load_delta_positive_threshold = 0xac4;
maf_fault_default_load_location = 0x332a6;
calc_engine_loads_override_lsv_to_flow_multiplier_location = 0x1e346;
divide_by2_maf_load_high_vs_rpm_2dmap16_location = 0x7d18;
ipw_safe_change_load_source_threshold_location = 0x252a6;
load400_math_space = 0x4f9a8;


/*guard specific*/
regen_crankshaft_rotation_decays = 0x419b0;
regen_crankshaft_rotation_decays_call_location = 0x18668;
obd_rest_handler_injection_location = 0x5ef34;

cruise_control_call_location = 0x1b890;
cruise_control = 0x1b8ec;

get_ig1 = 0x14410;

eeprom_start_area = 0x3b108;

sio0_rx_buffer = 0x8053d4;
sio0_tx_buffer = 0x8053ea;
sio0_tx_count = 0x80542c;
age_x1_ignition = 0x8048fc;

decays_x1_signature = 0x804afc;

vin = 0x804568;
shadow_vin = 0x80456c;
vin_volatility = 0x804570;

nlts_rpm_error = 0x804572;
nlts_flags = 0x804574;
nlts_state = 0x804576;
nlts_target_rpm = 0x804578;

overrev_spark_limit = 0x80457a;
overrev_cycle_decay = 0x80457c;
init_overrev_spark_limit = 0x80457e;
overrev_spark_limit_dec_step = 0x804580;
revolution_limit = 0x804582;

knock_mil_flags = 0x804584;
knock_mil_state = 0x804586;

new_mode_idx = 0x804588;

persistent_alt_mode_index = 0x80458a;
alt_mode_change_cel_flash_pattern = 0x80458c;

position_lights = 0x80458e;
position_lights_prev = 0x80458f;

decays_x1_knock_mil_flash = 0x804b00;
decays_x1_mil_pulse_timer = 0x804b02;

decays_x1_nlts_active = 0x804afe;

update_mil = 0x2f57c;
update_mil_call_location = 0x2e2fc;
update_gpio_outputs = 0x147d4;
update_gpio_outputs_call_location = 0x1b8bc;

calc_iat_call_location = 0x1cfd0;
calc_iat = 0x1d244;

maf_charge_aprx_bound_calc_location = 0x3326c;
adc_convert_maf_call_location = 0x35680;
adc_convert_maf = 0x144f8;

can0_40ms_tx_call_location = 0x38f18;

can0_slot12_rx_update_call_location = 0x49160;


MEMORY {
	UNUSED_MEMORY_FOR_MODS : ORIGIN = 0x56130, LENGTH =0x1000
	UNUSED_RAM_FOR_MODS : ORIGIN = 0x80553c, LENGTH = 0x20
}

get_coil_dwell = 0x32ddc;

SECTIONS {
	"Omni#1" 0x68eac : {
		*(.text)
		*(.rodata)
		*(.rodata*)
	}

	"Get coil dwell injection site#1 [m32r-bl]" 0x31cc0 : {
		LONG(new_get_coil_dwell_in_interrupt)
	}
	"Get coil dwell injection site#2 [m32r-bl]" 0x32e98 : {
		LONG(new_get_coil_dwell_in_interrupt)
	}


	"RAM" : {
		*(COMMON)
	} > UNUSED_RAM_FOR_MODS

	"data_desc" 0x60000 : {
		*(data_desc)
	}
}
