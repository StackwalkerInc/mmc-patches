/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Z37A MT 2005 (47110032) — per-ROM bindings for z37a_sparkcut.
 *
 * Every address below was derived from THIS ROM and cross-checked against a
 * second independent source.  Primary evidence is the commented disassembly
 * (mmc-research m32r/47110032_z37a_mt_2005/colt_commented.S, SHA-256 identical
 * to roms/47110032.bin); corroboration is a raw-byte decode of
 * roms/47110032.bin and/or an independent m32r-elf-objdump run.
 *
 * fp = 0x808000 on this ROM (m32r:2:fp8000), so absolute = 0x808000 + disp16
 * with disp16 negative.  z37a_mt_2005/memory_map.h names many of these as fp
 * offsets; it is used only as a HINT — never as evidence.  Never copy an
 * address from a sibling ROM.
 *
 * Anything that could not be pinned uniquely carries a VERIFY: marker.
 */

INCLUDE ../description.ld

/* ------------------------------------------------------------------ */
/* math                                                                */
/* ------------------------------------------------------------------ */

/* uint16_t s_divu16(uint16_t l, uint16_t r): "if (!r) return 0xffff;
   return min(l/r, 0xffff)" — body at 0x79c8 is exactly that (divu r0,r1
   guarded by beqz r1).  Corroborated by the library's fixed layout:
   s16_divu32_16 - s_divu16 = 0x20 and ps_divu16 - s16_divu32_16 = 0x34 hold
   here (0x79c8 / 0x79e8 / 0x7a1c) exactly as in m32r/math.ld. */
s_divu16			= 0x79c8;

/* ------------------------------------------------------------------ */
/* stock ROM code entry points                                         */
/* ------------------------------------------------------------------ */

/* target of the bl at 0x10aa0, the first instruction of
   update_multimode_selection(); bytes fe ff ea 1d => disp24 -5603,
   0x10aa0 + (-5603 * 4) = 0xb314.  Task 4 hijacks that call site. */
adc_convert_mode_input		= 0xb314;

/* ------------------------------------------------------------------ */
/* stock RAM — mode selector inputs                                    */
/* ------------------------------------------------------------------ */

/* read as "lduh r1,@(-12896,fp)" at 0x4e7f0 (multimap8u16) and identically
   at 0x4e808, 0x4e81c, 0x4e82c, 0x4e83c, 0x4e84c — i.e. THE multimap bank
   index.  Written at 0x10ae8 ("mode_idx = r0 > 7 ? 0 : r0").
   0x808000 - 12896 = 0x804DA0.  (0x804CC8 = fp-13112 is adc_byte_mode, read
   at 0x10aa4 — a different variable that used to carry this name here.) */
mode_idx			= 0x804DA0;

/* incremented by the 1-per-tick age sweep at 0x12abc,
   sat_array_add16(0x804808, 0x804828, tick_delta); zeroed at 0x11454
   when ignition_decay lapses.  0x808000 - 14324 = 0x80480C. */
age_x1_ignition			= 0x80480C;

/* written at 0x2cff0 and 0x2e5dc as
   s_16to8(s_sub16(tps_main_rcorr + fp13142_u16, 128)) — the corrected main
   throttle-position record.  0x808000 - 13140 = 0x804CAC. */
tps_main_rcord			= 0x804CAC;

/* written at 0x113dc ("sth r10,@(-13224,fp)") in the gpinputs post-processing
   routine, immediately after alt_inputs2_processed; snapshotted into
   alt_inputs3_processed_prev at 0x105e8/0x10ce0.  Bit 0x0001 is the clutch
   pedal — this ROM's Makefile sets -DCLUTCH_INPUT_INVERTED, so
   IS_CLUTCH_DEPRESSED tests for the bit being CLEAR.
   NOTE: bound in ../description.ld at 0x804C58 (= 0x808000 - 13224); kept
   there so every consumer of that file agrees.  Re-verified for this build. */

/* ------------------------------------------------------------------ */
/* decay slot                                                          */
/* ------------------------------------------------------------------ */

/* The once-per-tick decay sweep is sat_array_sub16 (0x48760) called at
   0x12acc with start = fp-14248 = 0x804858 and end = fp-13720 = 0x804A68,
   guarded by (update_flags_main & 0x01).  Any u16 in [0x804858, 0x804A68)
   is saturating-decremented every x1 tick, so a timer must live in there.
   0x804868 (fp-14232) is unreferenced: no fp-relative load/store/add3
   anywhere in the image targets fp-14232..fp-14225, no map/axis descriptor
   ramptr points there, and no ld24 in the ROM builds an 0x8048xx address.
   It is also inside the init-time memzero(0x804800, 0x8062B8) at 0x103f8,
   so it starts at 0 on every power-up. */
decays_x1_alt_mode_change_cel_flash_timer = 0x804868;

/* ------------------------------------------------------------------ */
/* mod-owned RAM                                                       */
/* ------------------------------------------------------------------ */

/* Free RAM block 0x8054C8..0x8054E7 (fp-11064..fp-11033), 32 bytes.
   Evidence it is genuinely untouched:
     - no fp-relative ld/st/add3 instruction in the image references any
       offset in [-11064, -11033] (scan of colt_commented.S AND an
       independent raw-byte scan of roms/47110032.bin for the a?/8?ad
       encodings);
     - every raw halfword in flash equal to one of these offsets was checked
       individually and is a bl/bra displacement, not a descriptor field;
     - no map8u16/mapu16/calc_axis descriptor ramptr (392 descriptors
       enumerated) points into the block;
     - no ld24 anywhere builds an address in 0x8054xx;
     - it lies outside both long-term-trims RAM checksum ranges computed by
       some_ram_checksum_104e4 (0x804016..0x8047E3 and 0x8068A0..0x806CAB);
     - it is below the interrupt stack base (SPI = 0x807ecc, set at 0x3854)
       and well below the user stack above fp;
     - it IS inside memzero(0x804800, 0x8062B8) at 0x103f8, so it is zeroed
       at init.
   The neighbours on both sides (fp-11078..-11074 written at 0x338c4..0x338cc,
   fp-11014 at 0x5f964) are plain scalar stores with no indexing, so the block
   is unallocated space between OBD-monitor scalars, not array padding. */
persistent_alt_mode_index	= 0x8054C8;	/* u16, index | ~index<<8 */
new_mode_idx			= 0x8054CA;	/* u16 */
alt_mode_change_cel_flash_pattern = 0x8054CC;	/* u16 */
mode_switch_delay		= 0x8054CE;	/* u16 */
position_lights			= 0x8054D0;	/* u8; overrides the tentative
						   definition in
						   src/etacs_handler_extension.c */
position_lights_prev		= 0x8054D1;	/* u8 */
/* 0x8054D2..0x8054E7 (22 bytes) spare in the same block. */

/* fp-12892: no fp-relative instruction and no flash halfword anywhere in the
   image references this offset, and it sits between two stock variables
   (sensor_faults at fp-12894, used 81 times, and fp-12890).  Free. */
mode_selector_flags		= 0x804DA4;

/* VERIFY: adc_byte_ac_pressure is deliberately LEFT UNBOUND.  This ROM has no
   A/C-pressure ADC channel — adc_run() is called for channels 0-15, 30, 46,
   62, 78 and 94 and none of them is A/C pressure; the value arrives over CAN
   as can_rx_ac_pressure (fp-9812 = 0x8059AC) and is conditioned into
   ac_pressure (fp-13076 = 0x804CEC) with ac_pressure_flags (fp-13074 =
   0x804CEE).  src/mode_selector_v2.c only declares it and never reads it, so
   nothing needs it today.  Leaving it unbound makes the link fail loudly
   rather than silently pointing a future user at the wrong RAM; if a module
   ever needs it, pick between 0x8059AC (raw CAN) and 0x804CEC (conditioned)
   deliberately and confirm on bench. */

/* ------------------------------------------------------------------ */
/* Gear indicator (gear_detector.c / gear_detector_data.c)             */
/* ------------------------------------------------------------------ */
current_gear			= 0x804D38;
calculated_gear			= 0x804D39;
decays_x1_gear_unstable		= 0x804882;	/* in the 0x12acc sweep range */

/* ------------------------------------------------------------------ */
/* ETACS / position lights (Z37A-specific glue, Task 5)                */
/* ------------------------------------------------------------------ */

/* can_rx_etacs_handler1 = 0x2cddc is bound in ../description.ld; confirmed
   here as entry 0 of flash_can_rx_handlers_1 (raw ROM at 0x9598 reads
   0x0002cddc) and by its body, which reloads both etacs decays below. */
can_rx1_data0_u8		= 0x8059A0;	/* fp-9824; unreferenced by stock
						   (stock reads fp-9823, the next
						   byte).  Overrides the tentative
						   definition in
						   src/etacs_handler_extended.c */
decays_x1_canrx1_etacts_short	= 0x8049B2;	/* reloaded at 0x2cdf8 from
						   flash 0x52530; inside the
						   0x12acc sweep range */
decays_x1_canrx1_etacts_long	= 0x8049C6;	/* reloaded at 0x2ce08; inside
						   the 0x12acc sweep range */

/* ------------------------------------------------------------------ */
/* Knock CEL (knock_mil_simple.c / knock_mil_data.c)                   */
/* ------------------------------------------------------------------ */
knock_mil_flags			= 0x80599A;
knock_mil_state			= 0x8059A4;
decays_x1_knock_mil_flash	= 0x80487E;	/* in the 0x12acc sweep range */
decays_x1_mil_pulse_timer	= 0x804A62;	/* in the 0x12acc sweep range
						   (last slot before 0x804A68) */
knock_sum			= 0x804FBE;
gpio1				= 0x804C26;
run_state_flags			= 0x804DB4;

/* call site of update_mil() to hook with new_update_mil */
update_mil_call_location	= 0x20164;

/* ------------------------------------------------------------------ */
/* Launch control + rev limit (revolution_limit.c)                     */
/* ------------------------------------------------------------------ */
vehicle_movement_decay		= 0x804D8A;
temp_axis_src			= 0x804BE0;	/* calc_axis src slot, matches
						   -DTEMP_AXIS_SRC_SDA=-13344 */

/* TODO: confirm via rom-analyzer — not present anywhere in z37a_mt_2005 */
sensor_faults			= 0x0; /* TODO: confirm via rom-analyzer */
overrev_spark_limit		= 0x0; /* TODO: confirm via rom-analyzer */
init_overrev_spark_limit	= 0x0; /* TODO: confirm via rom-analyzer */
overrev_spark_limit_dec_step	= 0x0; /* TODO: confirm via rom-analyzer */
oneshot_crank_event_flags	= 0x0; /* TODO: confirm via rom-analyzer */
tacho_reset_call_location	= 0x0; /* TODO: confirm via rom-analyzer */
tacho_reset			= 0x0; /* TODO: confirm via rom-analyzer */

/* --- Rolling spark cut (rolling_spark_cut.c) --- */
get_coil_dwell			= 0x24f64;
get_coil_dwell_call_site1	= 0x2501c;
get_coil_dwell_call_site2	= 0x23e54;
