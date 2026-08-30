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

/* ==================================================================
   Stock-ROM bindings shared by every 47110032 patch variant.
   These describe the stock ROM itself -- its routines, its RAM globals
   and its flash tables -- so they belong here rather than in any one
   variant's description.ld.  Addresses a patch *allocates* (mod-owned
   RAM, free slots it claims, per-variant constants) stay with the
   variant that owns them.
   ================================================================== */

/* ------------------------------------------------------------------ */
/* stock ROM code entry points                                        */
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

/* call site of update_mil() to hook with new_update_mil */
update_mil_call_location	= 0x20164;

/* --- Rolling spark cut (rolling_spark_cut.c) --- */
get_coil_dwell			= 0x24f64;

get_coil_dwell_call_site1	= 0x2501c;

get_coil_dwell_call_site2	= 0x23e54;

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


/* ------------------------------------------------------------------ */
/* stock RAM globals                                                  */
/* ------------------------------------------------------------------ */

/* read as "lduh r1,@(-12896,fp)" at 0x4e7f0 (multimap8u16) and identically
   at 0x4e808, 0x4e81c, 0x4e82c, 0x4e83c, 0x4e84c — i.e. THE multimap bank
   index.  Written at 0x10ae8 ("mode_idx = r0 > 7 ? 0 : r0").
   0x808000 - 12896 = 0x804DA0.  (0x804CC8 = fp-13112 is adc_byte_mode, read
   at 0x10aa4 — a different variable that used to carry this name here.) */
mode_idx			= 0x804DA0;

/* stock ADC mode input.  update_multimode_selection reads it one instruction
   after the call it feeds, as (adc_byte_mode >> 5) & 7, and indexes the mode
   table at 0x5002a with the result.  0x808000 - 13112 = 0x804CC8.

   Its only producer in the stock image is adc_convert_mode_input (0xb314),
   which on this ROM is the three-instruction stub "adc_byte_mode = 0;
   return", so the value is always 0 unless a patch supplies one. */
adc_byte_mode			= 0x804CC8;

/* incremented by the 1-per-tick age sweep at 0x12abc,
   sat_array_add16(0x804808, 0x804828, tick_delta); zeroed at 0x11454
   when ignition_decay lapses.  0x808000 - 14324 = 0x80480C. */
age_x1_ignition			= 0x80480C;

/* written at 0x2cff0 and 0x2e5dc as
   s_16to8(s_sub16(tps_main_rcorr + fp13142_u16, 128)) — the corrected main
   throttle-position record.  0x808000 - 13140 = 0x804CAC. */
tps_main_rcord			= 0x804CAC;

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

knock_sum			= 0x804FBE;

gpio1				= 0x804C26;

run_state_flags			= 0x804DB4;

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
   Consistent with mode_selector_flags in the variant description.ld,
   whose own derivation names "sensor_faults at fp-12894, used 81
   times" as its neighbour. */
sensor_faults			= 0x804DA2;

/* ------------------------------------------------------------------ */
vehicle_movement_decay		= 0x804D8A;

temp_axis_src			= 0x804BE0;	/* calc_axis src slot, matches
						   -DTEMP_AXIS_SRC_SDA=-13344 */


/* ------------------------------------------------------------------ */
/* stock flash tables and axes                                        */
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
