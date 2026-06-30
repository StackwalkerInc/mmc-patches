/* SPDX-License-Identifier: GPL-3.0-or-later */
/* NLTS patch sections — subset that maps to the Evo X CZ4A.
   `const128_nominal_ipw_multiplier_call_location` (used by the
   `Post fuel cut enrichment` section in the shared ../nlts.ld) has
   no known address on this ROM, so it is omitted. revolution_limit.c
   still compiles in its `update_post_fuel_cut_enrichment` function,
   it just isn't hooked. */

"Fuel cut for nlts/launch [m32r-bl]" fuel_cut_splice_into_location : {
	LONG(update_run_state_extended_flags_overrev)
}

"Post fuel cut spark limit [m32r-bl]" test_substitute_spark_advance_int_call_localtion : {
	LONG(new_test_substitute_spark_advance_int)
}

"Kill spark for X cycles after fuel cut [m32r-bl]" tacho_reset_call_location : {
	LONG(new_tacho_reset)
}
