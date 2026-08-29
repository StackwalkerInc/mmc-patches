// SPDX-License-Identifier: GPL-3.0-or-later
#include "gear_detector_data.h"

#include <maps_desc.h>

#define GEAR_THRESHOLD_DEF(target, inth, outth)                                                                        \
	{                                                                                                                  \
	    .low_in = target - inth,                                                                                       \
	    .low_out = target - outth,                                                                                     \
	    .high_in = target + inth,                                                                                      \
	    .high_out = target + outth,                                                                                    \
	}

/* ---- Gearbox ratio sets -------------------------------------------------
   Unitless gear ratios as published for the gearbox itself, so every vehicle
   fitted with it shares one definition. A vehicle contributes only its scale
   (below); final drive, tyre circumference and the ROM's speed/rpm units are
   all absorbed there.

   These are compile-time constants only. GCC folds them during translation
   (a file-scope const initialiser is a constant-expression context), so no
   floating point reaches the target -- M32R has no FPU. If a ratio ever
   escaped into a runtime expression the link would fail on __divdf3 rather
   than silently emitting soft-float, because we build -nostdlib. */

/* Getrag 453 (F5MGB), 5-speed -- Colt RG / RZ. */
#define F5MGB_G1 3.538
#define F5MGB_G2 1.913
#define F5MGB_G3 1.344
#define F5MGB_G4 1.027
#define F5MGB_G5 0.833

/* W5M6A, 5-speed -- Lancer Evolution X (CZ4A). */
#define W5M6A_G1 2.857
#define W5M6A_G2 1.950
#define W5M6A_G3 1.444
#define W5M6A_G4 1.096
#define W5M6A_G5 0.761

/* GEARBOX_SCALE is the threshold a hypothetical 1:1 gear would produce.
   Derived thresholds are GEARBOX_SCALE / ratio. */
#define GEAR_TARGET(ratio) ((gear_ratio_t)(GEARBOX_SCALE / (ratio) + 0.5))
#define GEAR_THRESHOLD_RATIO(ratio, inth, outth) GEAR_THRESHOLD_DEF(GEAR_TARGET(ratio), inth, outth)

/* The array is always six entries: src/gear_detector.c bounds its
   early-return check with itemsof(), and a five-speed pads by repeating top
   gear, which the scan loop can never select because it breaks on the first
   match. */

#if MACHINE_Z27AGMT
/* Colt Ralliart Version-R Z27AG, F5MGB.

   NOTE: these are literal thresholds, not derived, because they are wrong.
   Gears 1-2 match F5MGB exactly (implied 3.538 / 1.913); gears 3-5 imply
   1.434 / 1.100 / 0.868 against the published 1.344 / 1.027 / 0.833 -- note
   1.434 vs 1.344, a transposition -- and entry 6 implies a 0.693 sixth gear
   that a five-speed does not have. Its band starts 5711 counts above the
   highest ratio any real gear produces, so it can never match.

   Corrected in the following commit; kept verbatim here so this commit is
   provably byte-identical on the two shipped 33520003 targets. */
const struct gear_threshold flash_gear_thresholds[6] = {
    GEAR_THRESHOLD_DEF(9570, 1000, 1500),  GEAR_THRESHOLD_DEF(17699, 1500, 2000), GEAR_THRESHOLD_DEF(23611, 2000, 2500),
    GEAR_THRESHOLD_DEF(30781, 2500, 3000), GEAR_THRESHOLD_DEF(39008, 2500, 3000), GEAR_THRESHOLD_DEF(48858, 2500, 3000),
};
#elif MACHINE_Z37A_MT
/* Colt CZT Z37A, F5MGB -- same gearbox as Z27AG, different ROM scaling. */
#define GEARBOX_SCALE 29365.40
const struct gear_threshold flash_gear_thresholds[6] = {
    GEAR_THRESHOLD_RATIO(F5MGB_G1, 500, 1000), GEAR_THRESHOLD_RATIO(F5MGB_G2, 600, 1200),
    GEAR_THRESHOLD_RATIO(F5MGB_G3, 600, 1200), GEAR_THRESHOLD_RATIO(F5MGB_G4, 600, 1200),
    GEAR_THRESHOLD_RATIO(F5MGB_G5, 600, 1200), GEAR_THRESHOLD_RATIO(F5MGB_G5, 600, 1200),
};
#elif MACHINE_EVOX_MT
/* Evo X CZ4A 5MT, W5M6A, stock final drive. */
#define GEARBOX_SCALE 27405.64
const struct gear_threshold flash_gear_thresholds[6] = {
    GEAR_THRESHOLD_RATIO(W5M6A_G1, 1000, 2000), GEAR_THRESHOLD_RATIO(W5M6A_G2, 1000, 2000),
    GEAR_THRESHOLD_RATIO(W5M6A_G3, 1000, 2000), GEAR_THRESHOLD_RATIO(W5M6A_G4, 1000, 2000),
    GEAR_THRESHOLD_RATIO(W5M6A_G5, 2000, 4000), GEAR_THRESHOLD_RATIO(W5M6A_G5, 2000, 4000),
};
#elif MACHINE_EVOX_MT_GP43
/* Same car and gearbox as MACHINE_EVOX_MT, with a custom aftermarket final
   drive gear set in the stock case. Only the scale differs -- it comes out
   ~1.0698x the stock car's, which is the final-drive change (and any tyre
   difference) folded into one number. Not a factory variant. */
#define GEARBOX_SCALE 29318.40
const struct gear_threshold flash_gear_thresholds[6] = {
    GEAR_THRESHOLD_RATIO(W5M6A_G1, 1000, 2000), GEAR_THRESHOLD_RATIO(W5M6A_G2, 1000, 2000),
    GEAR_THRESHOLD_RATIO(W5M6A_G3, 1000, 2000), GEAR_THRESHOLD_RATIO(W5M6A_G4, 1000, 2000),
    GEAR_THRESHOLD_RATIO(W5M6A_G5, 2000, 4000), GEAR_THRESHOLD_RATIO(W5M6A_G5, 2000, 4000),
};
#endif

DECLARE_ARRAY_DESC(flash_gear_thresholds, "NLTS", "Gear Detector Ratio Thresholds", "uint16",
                   "<table name=\"Y\" type=\"Static Y Axis\" elements=\"24\">"
                   "<data>1 Low Out</data>"
                   "<data>1 Low In</data>"
                   "<data>1 High In</data>"
                   "<data>1 High Out</data>"
                   "<data>2 Low Out</data>"
                   "<data>2 Low In</data>"
                   "<data>2 High In</data>"
                   "<data>2 High Out</data>"
                   "<data>3 Low Out</data>"
                   "<data>3 Low In</data>"
                   "<data>3 High In</data>"
                   "<data>3 High Out</data>"
                   "<data>4 Low Out</data>"
                   "<data>4 Low In</data>"
                   "<data>4 High In</data>"
                   "<data>4 High Out</data>"
                   "<data>5 Low Out</data>"
                   "<data>5 Low In</data>"
                   "<data>5 High In</data>"
                   "<data>5 High Out</data>"
                   "<data>6 Low Out</data>"
                   "<data>6 Low In</data>"
                   "<data>6 High In</data>"
                   "<data>6 High Out</data>"
                   "</table>");

const uint16_t flash_init_gear_unstable = 2;
