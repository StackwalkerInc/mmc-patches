
"Fuel cut for nlts/launch [m32r-bl]" fuel_cut_splice_into_location : {
	LONG(update_run_state_extended_flags_overrev)
}

"Post fuel cut spark limit [m32r-bl]" test_substitute_spark_advance_int_call_localtion : {
	LONG(new_test_substitute_spark_advance_int)
}

"Kill spark for X cycles after fuel cut [m32r-bl]" tacho_reset_call_location : {
	LONG(new_tacho_reset)
}

"Post fuel cut enrichment [m32r-bl]" const128_nominal_ipw_multiplier_call_location : {
	LONG(update_post_fuel_cut_enrichment)
}
