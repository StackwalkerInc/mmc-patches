	"Guards#1 [m32r-bl]" obd_rest_handler_injection_location : { LONG(obd_rest_handler) }
	"Guards#2 [m32r-bl]" regen_crankshaft_rotation_decays_call_location : { LONG(injected_regen_crankshaft_rotation_decays) }
	"Guards#3" eeprom_start_area : {
		LONG(vin)
		LONG(vin + 1)
		LONG(vin + 2)
		LONG(vin + 3)
		LONG(shadow_vin)
		LONG(shadow_vin + 1)
		LONG(shadow_vin + 2)
		LONG(shadow_vin + 3)
	}
	"Guards#4 [m32r-bl]" cruise_control_call_location : { LONG(prestart_checks) }
