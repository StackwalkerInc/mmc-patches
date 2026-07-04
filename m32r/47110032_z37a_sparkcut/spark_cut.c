/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Spark-cut rev limiter for Colt CZT Z37A (47110032).
 * Injected at 0x1b2cc, replacing `sth r0,@(-12388,fp)` (the coil-dwell store).
 *
 * Logic:
 *   If vehicle_speed_hires <= sc_state_threshold (20):
 *       use sc_preset_cut_period (0x0805) as threshold
 *   Else:
 *       threshold = flash_revolution_period_limit * sc_rev_limit_multiplier / sc_rev_limit_divisor
 *                 = flash_rev_limit * 105 / 100  (5% above stock cut period)
 *
 *   If threshold >= shaft_period1_copy_dline0 (RPM at/above cut point):
 *       zero the coil-dwell value -> spark cut
 *   Else pass through.
 */
#include "../../include/maps_desc.h"

/*
 * Params block placed at 0x5fed0 in flash by the linker.  The struct
 * guarantees the exact byte layout — individual global variables in a
 * custom section would be reversed by GCC.
 *
 * volatile: prevents GCC from constant-folding flash reads at -Os so that
 * EcuFlash edits take effect at runtime.
 *
 * Layout (16 bytes, 0x5fed0-0x5fedf):
 *   +0x00  sc_state_threshold      uint16  0x0014
 *   +0x02  sentinel                uint16  0xFFFF
 *   +0x04  sc_preset_cut_period    uint16  0x0805
 *   +0x06  sentinel                uint16  0xFFFF
 *   +0x08  sc_rev_limit_divisor    int8    0x64
 *   +0x09  pad                     uint8   0x64
 *   +0x0A  sentinel                uint16  0xFFFF
 *   +0x0C  sc_rev_limit_multiplier int8    0x69
 *   +0x0D  pad                     uint8   0x0B
 *   +0x0E  sentinel                uint16  0xFFFF
 */
static const volatile struct {
	unsigned short state_threshold;
	unsigned short _sentinel0;
	unsigned short preset_cut_period;
	unsigned short _sentinel1;
	signed char rev_limit_divisor;
	unsigned char _pad0;
	unsigned short _sentinel2;
	signed char rev_limit_multiplier;
	unsigned char _pad1;
	unsigned short _sentinel3;
} params __attribute__((section(".spark_cut_params"))) = {
    .state_threshold = 0x0014,
    ._sentinel0 = 0xFFFF,
    .preset_cut_period = 0x0805,
    ._sentinel1 = 0xFFFF,
    .rev_limit_divisor = 0x64,
    ._pad0 = 0x64,
    ._sentinel2 = 0xFFFF,
    .rev_limit_multiplier = 0x69,
    ._pad1 = 0x0B,
    ._sentinel3 = 0xFFFF,
};

/*
 * Per-field linker symbols defined in description.ld alias the struct bytes.
 * These names are what EcuFlash sees as editable tables.
 */
extern const volatile unsigned short sc_state_threshold;   /* 0x5fed0 */
extern const volatile unsigned short sc_preset_cut_period; /* 0x5fed4 */
extern const volatile signed char sc_rev_limit_divisor;    /* 0x5fed8 */
extern const volatile signed char sc_rev_limit_multiplier; /* 0x5fedc */

DECLARE_VALUE_DESC(sc_state_threshold, "SparkCut", "State Threshold", "SpeedHires");
DECLARE_VALUE_DESC(sc_preset_cut_period, "SparkCut", "Preset Cut Period", "CrankPeriod");
DECLARE_VALUE_DESC(sc_rev_limit_divisor, "SparkCut", "Rev Limit Divisor", "Unitless");
DECLARE_VALUE_DESC(sc_rev_limit_multiplier, "SparkCut", "Rev Limit Multiplier", "Unitless");

/* Flash constant */
extern const unsigned short flash_revolution_period_limit;

/* RAM variables (fp_base = 0x808000) */
extern unsigned short vehicle_speed_hires;       /* 0x804d84 */
extern unsigned short active_cut_threshold;      /* 0x802120 */
extern unsigned short shaft_period1_copy_dline0; /* 0x8052b2 */
extern unsigned short coil_dwell_target;         /* 0x804f9c */

/*
 * Called via bl replacing `sth r0,@(-12388,fp)` at 0x1b2cc.
 * coil_dwell_value = r0 = the value that was about to be stored.
 */
void spark_cut(unsigned coil_dwell_value)
{
	unsigned short threshold;

	if (sc_state_threshold < vehicle_speed_hires)
		threshold = ((unsigned short)flash_revolution_period_limit / sc_rev_limit_divisor) * sc_rev_limit_multiplier;
	else
		threshold = sc_preset_cut_period;

	active_cut_threshold = threshold;
	if (threshold >= shaft_period1_copy_dline0)
		coil_dwell_value = 0;
	coil_dwell_target = (unsigned short)coil_dwell_value;
}
