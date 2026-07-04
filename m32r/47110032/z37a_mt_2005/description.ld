/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Z37A MT 2005 (47110032) — Mitsubishi Colt CZT Z37A 1.5T 5MT, 512KB flash.
   Different chip family from Z27AG: ROM ID lives at 0x50022 (not 0x222),
   different idle/torque calibration layout. Initial port targets the
   mmc-research patch scope: o2 rear-channel hijack + EDM APPS->TTP
   table descriptions. */

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
ps_divu16 = 0x7a1c;
