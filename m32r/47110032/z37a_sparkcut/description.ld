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

/* update_multimode_selection(): entry at 0x10a9c ("push lr || nop",
   2e 7f f0 00), ending "pop lr -> jmp lr" at 0x10c54 (2e ef 1f ce).  Three callers in
   the image, found by scanning BOTH bl encodings over raw bytes:
     - 0x1008c and 0x10414, 32-bit "bl" (fe 00 02 84 / fe 00 01 a2), both
       on the init path reached from main_loop's pre-loop prologue
       (0x4e13c -> 0x10064, 0x10188 -> 0x103f8), i.e. once per power-up;
     - 0x109e0, the 16-BIT form "7e 2f" (|| nop) inside
       base_engine_state_update (0x109dc), which main_loop calls at
       0x4e178 inside its `bra 0x4e148` loop -- the per-iteration caller.
   A 32-bit-bl-only scan sees only the two init callers, which is how the
   per-iteration clobber of mode_idx at 0x10ae8 went unnoticed.  The
   mode_bridge wrapper hijacks 0x109e0; see mode_bridge.c and omni.ld. */
update_multimode_selection	= 0x10a9c;

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
 *   - some_ram_checksum_104e4 (0x104e4) makes FOUR sum8_to16 (0x4e5fc)
 *     calls, each `add3 rN,fp,#-end` minus `add3 rM,fp,#-start` for the
 *     length and `#-start` for the pointer.  Hand-decoded from the raw
 *     bytes at 0x104ec-0x10540 (80adc58e 81adc016 / 82adc7e4 83adc638 /
 *     81adecac 82ade8a0 / 81adc7d9 82adc7c4), fp = 0x808000:
 *         sum8_to16(0x804016, 1400) -> [0x804016,0x80458E)
 *         sum8_to16(0x804638,  428) -> [0x804638,0x8047E4)
 *         sum8_to16(0x8068A0, 1036) -> [0x8068A0,0x806CAC)
 *         sum8_to16(0x8047C4,   21) -> [0x8047C4,0x8047D9)
 *     The endpoint this block's argument rests on is the second range's:
 *     it stops at 0x8047E4 (from `add3 r2,fp,#-14364` at 0x104f8), and
 *     the fourth range ends earlier still, at 0x8047D9.  Nothing summed
 *     reaches [0x8047E6,0x804800).
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
/* Dash: mode RPM indication (dash_mode_rpm.c, Task 5)                 */
/* ------------------------------------------------------------------ */

/* cantx_engine_rpm binds to engine_rpm_direct_bound, the RAM value read
 * directly by can_tx2_id3_dash_update() (0x2c738) when it assembles the
 * engine-to-dash CAN frame (sid 0x308, CAN_TX3_ENGINE_TO_DASH_RPM in
 * z37a_mt_2005/can_ids.h):
 *
 *     2c7a8: lduh r0,@(-9906,fp)
 *     2c7ac: srli r0,#0x8
 *     2c7b0: and3 r0,r0,#0xff
 *     2c7b4: stb r0,@(-6231,fp)   # can_tx2_id3_source[1] = (engine_rpm_direct_bound >> 8) & 0xff
 *     2c7b8: ldub r1,@(-9905,fp)
 *     2c7bc: and3 r2,r1,#0xff
 *     2c7c0: stb r2,@(-6230,fp)   # can_tx2_id3_source[2] = engine_rpm_direct_bound & 0xff
 *
 * fp-9906 = 0x808000 - 9906 = 0x80594E.
 *
 * DTC FAIL-SAFE (deliberately NOT overridden): the store above is the
 * else-half of a branch on a fault flag, cropped out of every excerpt in
 * the task reports and of the one in dash_mode_rpm.c:
 *
 *     2c78c: lduh r1,@(-15950,fp)      # fp15950_f16 @ 0x8041B2
 *     2c790: slli r1,#0x11 -> addx r1,r1   # C = bit 0x4000
 *     2c794: bnc 0x2c7a8               # clear -> take the store branch
 *     2c798: ldi r2,#-1 ; srli r2,#0x18    # r2 = 0xFF
 *     2c79c: stb r2,@(-6231,fp)        # can_tx2_id3_source[1] = 0xFF
 *     2c7a0: stb r2,@(-6230,fp)        # can_tx2_id3_source[2] = 0xFF
 *     2c7a4: bra 0x2c7c4
 *     2c7a8: ... (the engine_rpm_direct_bound store quoted above)
 *
 * i.e. `if (fp15950_f16 & 0x4000) { send 0xFF,0xFF } else { store }`.
 * With that DTC bit set the cluster is told "tach signal invalid" and
 * engine_rpm_direct_bound is not transmitted at all.  This patch writes
 * only the RAM variable and never touches 0x2c78c-0x2c7a4, so the
 * fail-safe still wins: under that fault the mode indication simply does
 * not appear.  That is intended -- suppressing a real tach-invalid
 * indication to show a cosmetic mode confirmation would be a regression.
 *
 * Two INDEPENDENT sources corroborate, per triangulating-tool-output:
 *   1. Instruction decoding above (colt_commented.S, disassembly).
 *   2. z37a_mt_2005/can_protocol.txt's hand-written frame layout notes,
 *      which independently document
 *          "sid 308 - engine to dash
 *           data[1-2] - engine_rpm_direct_bound BE"
 *      -- same variable name, same byte position, same big-endian order,
 *      from a document that is not disassembly text.
 * A third, structurally different source (z37a_mt_2005/frame_pointers.txt,
 * a generated fp-offset table, not hand-written and not disassembly) lists
 * "0x80594e  fp-9906  uint16_t fp9906_u16" -- confirming the address
 * arithmetic independently of both.
 *
 * can0_update_tx_data() (0x2c2e0, bound above) does NOT touch engine speed
 * at all -- it only computes cantx_target_idle_rpm, cantx_asc_active_lamp,
 * cantx_coolant_temp and similar unrelated fields. This is exactly the kind
 * of blind spot triangulating-tool-output warns about: the brief's
 * presumed location for "the store that takes engine_rpm into the TX slot
 * buffer" is not where that store actually lives. engine_rpm_direct_bound
 * is instead written earlier in the SAME main-loop iteration, at 0x11f38
 * (call_11598_11596_derived_calcs, called from base_engine_state_update at
 * 0x4e178) -- eight instructions before this task's injection site at
 * 0x4e1bc -- and read later, on its own ~800 Hz TIO3-interrupt-driven
 * schedule, by can_tx2_id3_dash_update() via calc_fast_engine_model()
 * (0x2d1f8, called from tio3_interrupt_handler_helper at 0xbd38/0xbd44).
 * engine_rpm_direct_bound is the only write site to fp-9906 other than the
 * cold-boot reset at 0x11e84 (zero references anywhere else in the ROM),
 * so it is the true feed for the dash frame, not a transient copy: our
 * override at 0x4e1bc lands after the stock recompute for that iteration
 * and persists (re-asserted every main-loop iteration for the whole CEL
 * flash window) until whatever ISR cadence next builds the CAN frame picks
 * it up.
 *
 * SCALE (medium confidence, resolved -- see dash_mode_rpm.c and
 * task-5-report.md for the full derivation): engine_rpm_direct_bound
 * carries real, unscaled RPM, not RPM_TO_HIRESTICKS ticks. Evidence: (a)
 * can_protocol.txt annotates scaling explicitly where it applies (e.g.
 * "sid 412 data[0-1] - fuel level (100% / 65536)") and is silent for
 * engine_rpm_direct_bound and for "sid 212 data[0-1] - target idle rpm",
 * consistent with both being the unscaled default; (b) the constant used
 * to derive engine_rpm_direct from the raw crank-period register
 * (0x7270e0 = 7,517,920) is within 0.24% of the K = clock_Hz*60/teeth
 * value a plain real-RPM formula would need for a plausible crank-capture
 * clock/tooth-count combination. This is NOT bench-verified; dash_mode_rpm.c
 * converts flash_mode_change_rpm_indication's hires-tick values back to
 * plain RPM (x*125/256, the exact inverse of RPM_TO_HIRESTICKS's *2.048)
 * rather than assigning them directly. */
cantx_engine_rpm		= 0x80594E;

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

/* sensor_faults: fp-12894 = 0x808000 - 12894 = 0x804DA2.  Proven from
   its bit-0x08 read-modify-write pair, decoded from raw bytes:
     12040: 84 ad cd a2  add3 r4,fp,#-12894
     12044: 20 b4 61 08  lduh r0,@r4 -> ldi r1,#8
     12048: 00 e1 20 24  or   r0,r1  -> sth r0,@r4      ; |= 0x08
     1205c: 85 ad cd a2  add3 r5,fp,#-12894
     12060: 20 b5 61 f7  lduh r0,@r5 -> ldi r1,#-9
     12064: 00 c1 20 25  and  r0,r1  -> sth r0,@r5      ; &= ~0x08
   guarded by a sensor-plausibility test at 0x12034 whose else-branch
   reloads the fault threshold from flash 0x52026.  A full scan of both
   addressing forms (`@(0xcda2,fp)` load/store and `add3 rN,fp,#-12894`)
   finds exactly 81 accesses across the image -- a heavily-used live
   variable, not slack.  Semantics corroborated independently by
   src/revolution_limit.c, which reads `sensor_faults & 0x08` to pick
   flash_maf_fault_revolution_period_limit: the same bit this pair sets.
   Consistent with mode_selector_flags below, whose own derivation already
   names "sensor_faults at fp-12894, used 81 times" as its neighbour.

   The remaining six TODO bindings below are a separate, pre-existing
   cleanup and are deliberately left alone here.  NOTE: `= 0x0` makes a
   future reference a silent write to address 0; prefer leaving a symbol
   UNBOUND (as adc_byte_ac_pressure is, below) so the link fails loudly. */
sensor_faults			= 0x804DA2;
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

/* ------------------------------------------------------------------ */
/* Top-region integrity guard (top_region_guard.c, Task 6)             */
/* ------------------------------------------------------------------ */

/* 0x4e130: push lr -> ldi r0,#7 (function prologue, confirmed by
   objdump); stock's 0x8080 PLT slot is `bra 0x4e130`. */
main_loop                  = 0x4e130;

/* 0x4c98: push lr -> ldi r0,#7; five bl's, then sth r0,@(-122,fp) with
   r0=1 (sets a flag, presumably integrity_fault), then bl 0x4cc0
   (bootloader_main), pop lr -> jmp lr. Confirmed by objdump against
   roms/47110032.bin. */
integrity_fault_reinit_mcu = 0x4c98;   /* bootloader: integrity_fault = 1; bootloader_main() */

/* Confirmed by objdump: every one of the 9 call sites in
   roms/47110032.bin (0x3ed18, 0x3ed6c, 0x3ede4, 0x3ee6c, 0x3eeec,
   0x4b174, 0x4b4a4, 0x5acf8, 0x5ad70) loads r0=0 immediately before the
   bl -- p0 is always 0 in this ROM, and 0x5ed0c never reads r0 again
   after the entry-critical-section call (bl 0x3910) clobbers it, so p0
   is effectively write-only/reserved here. p1 varies (2, 3, 4, 16...)
   and drives the branch at 0x5ed38/0x5ed4c. The call at 0x4b174 is
   `ldi r1,#3 -> ldi r0,#0` immediately followed by `bl 0x5ed0c`, i.e.
   exactly set_dtc(0, 3) as this file documents.
   Cross-check against Task 5's alternate candidate at 0x34458: that
   function is NOT this one -- it takes 3 args (r0/r1/r2, saved as
   r8/r9/and3'd r2 against #1) and has different branch structure. It is
   unrelated to the call guarded by GUARD_RAISE_P0606 here. */
set_dtc                    = 0x5ed0c;  /* called as set_dtc(0, 3) on ROM CRC failure at 0x4b174 */

/* Task 3's magic word at the base of TOP_EXT (omni.ld: "Top Region
   Magic" 0x60000 : { LONG(0x5a37a001) }); reads 0xffffffff on a stock
   or partially-flashed ROM, 0x5a37a001 once the top region is written. */
flash_top_region_magic     = 0x60000;
