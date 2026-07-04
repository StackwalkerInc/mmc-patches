/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Z37A MT 2005 (47110032) — symbol bindings for the standalone spark-cut
   patch.  Extend as additional RAM vars are identified via objdump. */

/* Per-field addresses into the params block at 0x5fed0 — used by DECLARE_VALUE_DESC */
sc_state_threshold		= 0x5fed0;
sc_preset_cut_period		= 0x5fed4;
sc_rev_limit_divisor		= 0x5fed8;
sc_rev_limit_multiplier		= 0x5fedc;

/* Flash constant */
flash_revolution_period_limit	= 0x51216;

/* RAM variables (fp_base = 0x808000, offsets confirmed via m32r-elf-objdump) */
vehicle_speed_hires		= 0x804d84;	/* @(-12924,fp); compared against state_threshold */
active_cut_threshold		= 0x802120;	/* @(-24288,fp); last computed cut threshold      */
shaft_period1_copy_dline0	= 0x8052b2;	/* @(-11598,fp); current shaft period (∝ 1/RPM)  */
coil_dwell_target		= 0x804f9c;	/* @(-12388,fp); zeroed to cut spark              */
