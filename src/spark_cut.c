// SPDX-License-Identifier: GPL-3.0-or-later
/*
 * spark_cut.c — franzcars spark-cut rev limiter, ported from binary to C source.
 *
 * Original: hand-crafted M32R binary blob by "franzcars" (2016–2017), distributed
 * as 25 per-ROM EcuFlash XML patches for CZ4A ROM variants.
 *
 * Mechanism (reverse-engineered from 53040010 Tephra v2/3 blob at 0xd5ff2/0xd6000):
 *   Replaces `sth r0,@(-13784,fp)` inside update_coil_dwell_mappings at 0x217c8.
 *   That instruction writes coil_dwell_optimal_rpm_x_power (the x16-scaled coil dwell
 *   cap).  Zeroing it causes update_coil_dwell() to clamp coil_dwell = 0, so the coil
 *   never charges and no spark fires regardless of ignition timing.
 *
 * Two operating modes (mirrors revolution_limit.c vehicle_movement_decay logic):
 *
 *   Moving (vehicle_movement_decay != 0):
 *     threshold = revolution_limit x flash_spark_cut_divider / 100
 *     Default (divider=105): threshold period ~= fuel_cut_period x 1.05
 *     -> spark cut fires just below the fuel-cut RPM.
 *
 *   Stationary (vehicle_movement_decay == 0):
 *     threshold = flash_spark_cut_stationary_rpm
 *     Fixed period limit for launch / 2-step use.
 *     Test at low RPM (e.g. 3000) before raising.
 *
 * Period domain: shaft periods are inverse-RPM (smaller period = faster).
 * "threshold >= shaft_period" means engine is at or above the cut RPM.
 *
 * Flash parameters placed by omni.ld (user-editable via EcuFlash by address):
 *   flash_spark_cut_divider        uint8   at 0xd5ff2
 *   flash_spark_cut_stationary_rpm uint16  at 0xd5ffa
 */

#include <stdint.h>

/* RPM divider x 100.  Default 105 -> spark cut at fuel_cut_period x 1.05.
 * Higher value = lower spark cut RPM relative to the fuel cut limit.
 * Set to 99 to disable the moving path entirely. */
extern const uint8_t flash_spark_cut_divider;

/* Stationary spark cut period limit (shaft period units, uint16).
 * Active when vehicle_movement_decay == 0 (stationary / launch / 2-step). */
extern const uint16_t flash_spark_cut_stationary_rpm;

/* Current fuel-cut shaft period set by update_revolution_limit.
 * On 53040110: 0x80877e.  Inverse-RPM: smaller value = higher RPM cutoff. */
extern uint16_t revolution_limit;

/* Live shaft period snapshot written by the CAS ISR each firing event. */
extern uint16_t shaft_period1_copy_dline0;

/* Nonzero when the vehicle has been moving recently; zero when stationary. */
extern uint16_t vehicle_movement_decay;

/* x16-scaled coil dwell cap written by update_coil_dwell_mappings.
 * update_coil_dwell() clamps coil_dwell = min(coil_dwell_optimal_rpm_x_power, ret);
 * zeroing this variable forces coil_dwell = 0 -> no coil charge -> no spark. */
extern uint16_t coil_dwell_optimal_rpm_x_power;

/*
 * new_coil_dwell_store -- replacement for `sth r0,@(-13784,fp)` at 0x217c8.
 *
 * Called via [m32r-bl] hook.  Receives the x16-scaled dwell cap that
 * update_coil_dwell_mappings computed; replicates the store, conditionally
 * zeroing it to cut spark.  Returns original_dwell unchanged so the caller
 * can continue with its unscaled _mut write (and3 r0 / srli r0,#4 / sth).
 */
uint16_t new_coil_dwell_store(uint16_t original_dwell)
{
	uint16_t threshold;

	if (vehicle_movement_decay) {
		threshold = (revolution_limit / 100) * flash_spark_cut_divider;
	} else {
		threshold = flash_spark_cut_stationary_rpm;
	}

	if (threshold >= shaft_period1_copy_dline0)
		coil_dwell_optimal_rpm_x_power = 0;
	else
		coil_dwell_optimal_rpm_x_power = original_dwell;

	return original_dwell;
}
