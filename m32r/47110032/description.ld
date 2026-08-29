/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Z37A MT 2005 (47110032) — Mitsubishi Colt CZT Z37A 1.5T 5MT, 512KB flash.
   Different chip family from Z27AG: ROM ID lives at 0x50022 (not 0x222),
   different idle/torque calibration layout. Initial port targets the
   mmc-research patch scope: o2 rear-channel hijack + EDM APPS->TTP
   table descriptions. */

/* Stock math/map library: this ROM splits it, with the scalar helpers and
   pushi/popi inside the bootloader region below 0x8000. */
MATH_PUSHI_BASE = 0x3910;
MATH_BASE       = 0x7600;
MATH_MAP_BASE   = 0x4e664;

INCLUDE ../../math-symbols.ld

/* idle/torque tables */
flash_idle_coolant_axis = 0x4ee26;
flash_target_idle_rpm_neutral_2dmap8 = 0x50220;
flash_icomp_base_neutral_2dmap8 = 0x50288;
flash_coolant_temp_icomp_coolant_axis = 0x4ecfe;
flash_coolant_temp_idle_compensation_2dmap8 = 0x5313e;
flash_target_idle_rpm_min_ac_on_neutral = 0x50190;
flash_target_idle_rpm_min_ac_onmax_neutral = 0x50196;

flash_tomo_apps_to_ttp_apps_axis = 0x567e4;
flash_tomo_apps_to_ttp_correction_max_2dmap8 = 0x56788;

flash_apps_to_ttp_correction_axis = 0x4f0f4;
flash_apps_to_ttp_correction_default_2dmap8 = 0x50acc;
flash_apps_to_ttp_correction_lowgear_2dmap8 = 0x50aec;

flash_tct_ttps_axis = 0x4eece;
flash_torque_calculations_rpm_axis = 0x4ee4c;
flash_tct_hg_3dmap16 = 0x50702;   /* Target Combustion Torque */
flash_tct_lg_3dmap16 = 0x5053e;

/* runtime + o2 hijack */
adc_run = 0xbad4;
adc_byte_o2_front = 0x804c80;
adc_byte_o2_rear = 0x804c84;
adc_byte_o2_rear_replacement = 0x804c82;
adc_full_o2_rear_replacement = 0x804c7e;


vehicle_speed_hires		= 0x804d84;	/* @(-12924,fp); compared against state_threshold */
shaft_period1_copy_dline0	= 0x8052b2;	/* @(-11598,fp); current shaft period (∝ 1/RPM)  */

/*for dash display can tx*/
flash_can_tx2_done_index = 0x9524;
flash_can_tx2_done_mask = 0x952b;
can_tx2_request = 0x41820;


mut_table_start = 0x3f484;
scale_can_vehicle_speed = 0x14420;

/* used for can topcall replacement*/
can0_update_bus_state = 0x2ba80;
can0_update_tx_data = 0x2c2e0;

/*etacs extension*/
flash_can_rx_handlers_1 = 0x9598;
can_rx_etacs_handler1 = 0x2cddc;

/*for gear indicator*/
can_vehicle_speed = 0x805bfe;
engine_rpm = 0x804cfc;

alt_inputs3_processed = 0x804c58;

map_engine_load = 0x804d30;
update_mil = 0x215f0;

update_gpio_outputs_call_location = 0x4e1c0;
update_gpio_outputs = 0xb324;
