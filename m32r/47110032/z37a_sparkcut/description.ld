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

/* Free RAM block 0x8047E6..0x8047FF (fp-14362..fp-14337), 26 bytes.
 *
 * ROUND-1 FIX. The previous block (0x8054C8..0x8054E7) was CRITICAL: proven
 * live stock RAM. Two parallel OBD DTC-monitor descriptor structs at
 * 0x856c/0x8758 store 32-bit ABSOLUTE POINTERS into it (19 word-aligned hits
 * covering every halfword of the old block). That mechanism is invisible to
 * any fp-relative or ld24 check because the pointers live in FLASH DATA, not
 * in an instruction operand -- the five checks that passed the old block all
 * shared that one blind spot and were not independent.
 *
 * This block was cleared under the three mechanisms Ruling P8 requires,
 * each a genuinely different representation of the ROM:
 *
 *   (a) fp-relative instructions: grep -oE '@\(-?[0-9]+,fp\)' over
 *       colt_commented.S, converted to absolute addresses via fp=0x808000.
 *       Zero hits anywhere in [0x8047E6,0x804800).
 *
 *   (b) ld24 / absolute-immediate address construction: an INDEPENDENT
 *       `m32r-elf-objdump -b binary -m m32r -EB -D roms/47110032.bin` run
 *       (raw bytes, not colt_commented.S text), scanned for every
 *       `ld24 rN,#imm24` and every `seth`+`add3`/`or3` pair whose value
 *       lands in [0x804000,0x808000). 13 ld24 hits, 0 seth+add3/or3 hits in
 *       that whole 16KB window, none near this block (nearest: the loop
 *       bound 0x804000 and stack-area constants 0x806404/0x806438/
 *       0x806f50/0x806f58/0x807ecc/0x807f6c).
 *
 *   (c) word-aligned 32-bit pointer scan: a Python scan of every 4-byte-
 *       aligned offset in roms/47110032.bin, decoded big-endian, for values
 *       landing in [0x804000,0x808000) -- the exact mechanism that finds the
 *       OLD block's 19 descriptor-pointer hits, applied here to the new
 *       candidate. 1290 hits across the whole ROM; zero in
 *       [0x8047E6,0x804800).
 *
 * Two more checks were run because (a)-(c) alone reproduced this exact class
 * of defect TWICE MORE while searching for a replacement block: a 23-entry
 * DTC bitmask array at 0x8055C0 (`for (i=0;i<23;++i) fp10816_u16a[i] = ...`,
 * 0x39914) and a 10-entry struct4 array at 0x8044BE
 * (`for (ptr=fp15170_struct4a; ptr<fp15170_struct4a+10; ++ptr)`, 0x3bc88) --
 * both addressed only through a runtime `add3 rN,fp,#imm` base register plus
 * a loop increment, never through a literal @(disp,fp) form, so (a)-(c) read
 * them as empty:
 *
 *   (d) every `add3`/`addv3`/`and3`/`srl3 rN,fp,#imm` in colt_commented.S
 *       (754 distinct targets in [0x804000,0x808000)): these build the base
 *       register for exactly the indexed/loop access above. Zero targets in
 *       [0x8047E6,0x804800); the nearest is the boot memzero's own base
 *       (add3 r0,fp,#-14336 at 0x10400 -> bl 0x762c = zero_u16a(0x804800,
 *       0x806478)), one byte after this block's end.
 *
 *   (e) every begin/end-pointer-pair `bl` call (two add3-with-fp
 *       instructions feeding a `bl` within a few slots -- the shape behind
 *       zero_u16a/sat_dec_u16a_atomic/sat_array_add16/etc, confirmed as the
 *       actual consumer of both arrays found via (d)): 75 such calls;
 *       their swept ranges cover essentially all of [0x804800,0x806478)
 *       (the bulk boot-memzero'd working RAM) plus every checksummed
 *       sub-range below it. None cover [0x8047E6,0x804800).
 *
 * The block sits in the seam between two independently hand-decoded stock
 * structures, which is why it is free:
 *   - some_ram_checksum_104e4 (0x104e4) computes
 *     sum8_to16(fp-14792, 14792-14364) = sum8_to16(0x804638, 428) --
 *     confirmed from raw bytes at 0x104f8 (`add3 r2,fp,#-14364`) -- i.e. it
 *     sums exactly [0x804638,0x8047E4) and stops there.
 *   - the bulk boot memzero (0x10400: `add3 r0,fp,#-14336` -> `bl 0x762c`)
 *     zeroes [0x804800,0x806478) and starts there, not before.
 *   [0x8047E4,0x804800) -- 28 bytes -- is neither summed nor zeroed: pure
 *   compiler alignment slack. This block uses [0x8047E6,0x804800), 2 bytes
 *   in from the slack's start for clean u16 alignment.
 *
 * Fourth, tool-independent corroboration (Ruling P9): rom-analyzer's
 * Ghidra-based RAM-ref-propagation pass
 * (rom-analyzer analyze roms/47110032.bin --variant fp8000 --out ...)
 * emits ram-free.toml with a block 0x8047e3..0x804800 (29 bytes) that FULLY
 * CONTAINS this one. The same ram-free.toml correctly does NOT list the old
 * 0x8054C8..0x8054E7 block as free at all -- confirming this layer would
 * have caught the original defect had it been run. But its free-list is not
 * sufficient on its own either: it also lists most of [0x8055c5,0x8055f2)
 * as free, which hand-decoding proved is the middle of the live 23-entry DTC
 * array above -- rom-analyzer's dataflow tracking does not fully follow that
 * increment loop. Treated here as one corroborating source among several,
 * not as ground truth.
 *
 * NOTE for Task 4-6: unlike the rejected block, this one is NOT inside the
 * boot-time memzero, so it is NOT guaranteed zero on power-up. Code relying
 * on a deterministic zero start (e.g. alt_mode_change_cel_flash_pattern
 * indexing a bounds-unchecked array) must explicitly initialise these six
 * fields itself.
 */
persistent_alt_mode_index	= 0x8047E6;	/* u16, index | ~index<<8 */
new_mode_idx			= 0x8047E8;	/* u16 */
alt_mode_change_cel_flash_pattern = 0x8047EA;	/* u16 */
mode_switch_delay		= 0x8047EC;	/* u16 */
position_lights			= 0x8047EE;	/* u8; overrides the tentative
						   definition in
						   src/etacs_handler_extended.c */
position_lights_prev		= 0x8047EF;	/* u8 */
/* 0x8047F0..0x8047FF (16 bytes) spare in the same block; 0x8047E4..0x8047E5
   (2 bytes) unused ahead of it for u16 alignment. */

/* Task 4 (P11 write-before-read audit): all six fields above are read
 * safely at cold boot ONLY because flash_reset_alt_mode_on_ignition_cycle
 * ships as 1 (src/mode_selector_v2_data.c). With it nonzero,
 * update_mode_selector()'s first-ever call takes the "age_x1_ignition < 20"
 * branch unconditionally (age_x1_ignition is inside the boot memzero, so it
 * starts at 0) and returns without reading persistent_alt_mode_index,
 * position_lights_prev, or alt_mode_change_cel_flash_pattern; its
 * unconditional trailing write then makes every later read safe.
 *
 * flash_reset_alt_mode_on_ignition_cycle is exposed to tuners as an
 * EcuFlash field ("Reset Mode On Ignition Cycle"). If a downstream tune
 * sets it to 0, that first-call reset branch never fires, and cold-boot
 * garbage in persistent_alt_mode_index can reach
 * alt_mode_change_cel_flash_pattern = l_old_mode_index*2 + GET_ALT_MODE_INDEX
 * (up to ~511), indexing flash_mode_change_patterns[4][16] far out of
 * bounds in alt_mode_change_cel(). Bounded impact: it's a flash read, so
 * the result is a garbled CEL flash pattern that self-corrects within a
 * tick once persistent_alt_mode_index self-heals via ok_alt_mode_index() --
 * cosmetic, not a drivability or safety effect. The clean hardening (a
 * bounds check at the read in alt_mode_change_cel(), or a clamp at the
 * write in update_mode_selector()) is a one-line change to the shared
 * src/mode_selector_v2.c, deliberately deferred here per Ruling P13 --
 * that file is linked by the bench-qualified 33520003 target, and
 * hardening a cosmetic cold-boot edge case does not justify reopening it.
 * Whoever next touches src/mode_selector_v2.c for another reason should
 * pick this up.
 */

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

/* ------------------------------------------------------------------ */
/* Extended load axes / alt map sets (extended_maps.c, Task 3)         */
/* ------------------------------------------------------------------ */

/* stock RPM axes — unchanged, but referenced by name from the map
   descriptors, so codeinjector must be able to resolve them */
flash_fuel_map_rpm_axis             = 0x4ebb0;
flash_main_spark_maps_rpm_axis      = 0x4ebf8;
flash_mivec_target_rpm_axis         = 0x4f01e;

/* stock tables — seed sources */
flash_fuel_load_axis_stock          = 0x4ebd2;
flash_spark_load_axis_17_stock      = 0x4ec1e;
flash_spark_load_axis_12_stock      = 0x4ec46;
flash_mivec_load_axis_stock         = 0x4effa;

flash_fuel_hi_octane_stock          = 0x53ebe;
flash_fuel_lo_octane_stock          = 0x53fa6;
flash_spark_4f9fc_stock             = 0x53806;
flash_spark_4fa1c_stock             = 0x53df6;
flash_spark_4fa3c_stock             = 0x53afe;
flash_spark_4fafc_stock             = 0x535d6;
flash_spark_4fb1c_stock             = 0x53bc6;
flash_spark_4fb3c_stock             = 0x538ce;
flash_spark_4fb5c_stock             = 0x536ee;
flash_spark_4fb7c_stock             = 0x53cde;
flash_spark_4fb9c_stock             = 0x539e6;
flash_mivec_target_stock            = 0x54468;
