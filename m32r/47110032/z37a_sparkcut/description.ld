/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Z37A MT 2005 (47110032) — modern-suite PoC bindings for z37a_sparkcut.
   Addresses cross-referenced from z37a_mt_2005/memory_map.h (same
   physical ROM) via absolute = 0x808000 - |fp_offset|; see
   docs/superpowers/plans/2026-07-05-z37a-sparkcut-modern-suite.md for
   the derivation. Never copy z37a_mt_2005's macro-based access code —
   only its addresses. */

INCLUDE ../description.ld

/* --- Gear indicator (gear_detector.c / gear_detector_data.c) --- */
current_gear			= 0x804D38;
calculated_gear			= 0x804D39;
decays_x1_gear_unstable		= 0x804882;

/* --- Map switching (mode_selector_v2.c) --- */
mode_idx			= 0x804CC8; /* adc_byte_mode in z37a_mt_2005 */
mode_selector_flags		= 0x804DA4;
age_x1_ignition			= 0x80480C;
tps_main_rcord			= 0x804CAC;

/* --- ETACS / position lights (Z37A-specific glue, Task 5) --- */
can_rx1_data0_u8		= 0x8059A0;
decays_x1_canrx1_etacts_short	= 0x8049B2;
decays_x1_canrx1_etacts_long	= 0x8049C6;

/* --- Knock CEL (knock_mil_simple.c / knock_mil_data.c) --- */
knock_mil_flags			= 0x80599A;
knock_mil_state			= 0x8059A4;
decays_x1_knock_mil_flash	= 0x80487E;
decays_x1_mil_pulse_timer	= 0x804A62; /* was decays_x1_mil_flash_timer in z37a_mt_2005 */
knock_sum			= 0x804FBE;
gpio1				= 0x804C26;
run_state_flags			= 0x804DB4;

/* call site of update_mil() to hook with new_update_mil */
update_mil_call_location	= 0x20164;

/* --- Launch control + rev limit (revolution_limit.c / revolution_limit_data.c) --- */
vehicle_movement_decay		= 0x804D8A;
temp_axis_src			= 0x804BE0;

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
get_coil_dwell_call_site1 = 0x2501c;
get_coil_dwell_call_site2 = 0x23e54;
