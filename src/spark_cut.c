// SPDX-License-Identifier: GPL-3.0-or-later
/*
 * spark_cut.c — franzcars spark-cut rev limiter, ported from binary to C source.
 *
 * Original: hand-crafted M32R binary blob by "franzcars" (2016–2017),
 * distributed in "Spark Cut Patchs txt" for 25 CZ4A ROM variants.
 * Algorithm reverse-engineered from the 53040010 Tephra v2/3 blob at
 * 0xd5ff2/0xd6000 via m32r-elf-objdump disassembly.
 *
 * This port chains into the existing NLTS overrev hook at
 * test_substitute_spark_advance_int_call_localtion (0x2c810 on 53040110).
 * new_spark_advance_with_cut wraps new_test_substitute_spark_advance_int
 * and applies the spark cut on top, so overrev protection is preserved.
 *
 * Two operating modes (mirrors revolution_limit.c vehicle_movement_decay logic):
 *
 *   Moving (vehicle_movement_decay != 0):
 *     threshold = revolution_limit x flash_spark_cut_divider / 100
 *     Default (divider=105): threshold period = fuel_cut_period x 1.05
 *     -> spark cut fires just above the fuel-cut RPM.
 *
 *   Stationary (vehicle_movement_decay == 0):
 *     threshold = flash_spark_cut_stationary_rpm
 *     Fixed period limit for launch / 2-step use.
 *     Test at ~3000 RPM before setting higher.
 *
 * Period domain: shaft periods are inverse-RPM (smaller period = faster).
 * "threshold >= shaft_period" means engine is at or above the cut RPM.
 *
 * Flash parameters placed by omni.ld (user-editable via EcuFlash by address):
 *   flash_spark_cut_divider        uint8   at 0xd5ff2
 *   flash_spark_cut_stationary_rpm uint16  at 0xd5ffa
 */

#include <stdint.h>

/*
 * Chained function: applies the overrev spark limit before the cut check.
 * Defined in revolution_limit.c, linked into the same ELF.
 */
extern uint16_t new_test_substitute_spark_advance_int(uint16_t p0);

/*
 * Flash-resident tunable parameters (placed by omni.ld).
 * EcuFlash edits these by their placed addresses.
 */

/* RPM divider x 100.  Default 105 -> spark cut at fuel_cut_period x 1.05.
 * Higher value = lower spark cut RPM relative to the fuel cut limit.
 * Range 100-255 (1.00x-2.55x).  Set to 99 to disable the moving path. */
extern const uint8_t flash_spark_cut_divider;

/* Stationary spark cut period limit (shaft period units, uint16).
 * Active when vehicle_movement_decay == 0 (stationary / launch / 2-step).
 * Default 0x09c4 (2500 period units).  Test at low RPM before raising. */
extern const uint16_t flash_spark_cut_stationary_rpm;

/*
 * RAM variables -- addresses resolved from description.ld / nlts_local.ld.
 */

/* Current fuel-cut shaft period set by update_revolution_limit.
 * Inverse-RPM: smaller value = higher RPM cutoff.
 * Used as the base from which the moving-mode threshold is derived. */
extern uint16_t revolution_limit;

/* Live shaft period snapshot written by the CAS ISR each firing event.
 * The cut fires when this drops below the computed threshold. */
extern uint16_t shaft_period1_copy_dline0;

/* Nonzero when the vehicle has been moving recently; zero when stationary.
 * Identical semantics to the launch-control gate in revolution_limit.c. */
extern uint16_t vehicle_movement_decay;

/*
 * new_spark_advance_with_cut -- replacement target for the NLTS hook at
 * test_substitute_spark_advance_int_call_localtion (0x2c810 on 53040110).
 *
 * Chains:
 *   1. new_test_substitute_spark_advance_int -- existing overrev spark limit.
 *   2. Spark cut -- zeros the advance when engine is at or above cut RPM.
 *
 * Returns the final spark advance value (0 when cutting).
 */
uint16_t new_spark_advance_with_cut(uint16_t p0)
{
	/* Preserve existing NLTS / overrev spark limiting behaviour. */
	p0 = new_test_substitute_spark_advance_int(p0);

	uint16_t threshold;

	if (vehicle_movement_decay) {
		/*
		 * Vehicle moving: place the spark cut threshold just above the fuel
		 * cut RPM.  In the period domain, a larger period means lower RPM, so
		 * multiplying by divider/100 (> 1.0) raises the threshold period,
		 * which lowers the cut RPM, ensuring the cut fires just before the
		 * fuel cut.
		 *
		 * Division before multiplication prevents 16-bit overflow at high
		 * period values; mirrors the div->mul instruction order in the original
		 * hand-coded M32R blob (53040010 d6040->d604c).
		 */
		threshold = (revolution_limit / 100) * flash_spark_cut_divider;
	} else {
		/*
		 * Vehicle stationary (launch / 2-step): use the fixed period limit.
		 * The stock fuel-cut rev limiter remains active in parallel.
		 */
		threshold = flash_spark_cut_stationary_rpm;
	}

	/*
	 * Cut when engine period <= threshold, i.e. engine RPM >= cut RPM.
	 * Returning 0 signals zero spark advance to the caller; the caller
	 * stores this to the spark advance RAM variables via sth r0, @(d, sp).
	 */
	if (threshold >= shaft_period1_copy_dline0)
		return 0;

	return p0;
}
