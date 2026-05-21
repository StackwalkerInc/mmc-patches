/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE description.ld

/* Free-space regions reclaimed from disabled stock features.
   The half-byte ranges [3c730, 3cd30) and [46738, 46e68) were scavenged
   from the stock idle-check and MDP/EVAP-extension routines. */
MEMORY {
	IDLE_CHECK              : ORIGIN = 0x3c730, LENGTH = 0x600
	MDP_EVAP_EXT_CHECK      : ORIGIN = 0x46738, LENGTH = 0x730
	LAST_UNUSED_FLASH       : ORIGIN = 0x5fc74, LENGTH = 0x38a
	MIDDLE_UNUSED_FLASH     : ORIGIN = 0x4fcbc, LENGTH = 0x344
	UPDATE_MIL_FLASH        : ORIGIN = 0x215f0, LENGTH = 0x358
	MD_CONTROL_IN_CALC_IPW  : ORIGIN = 0x25a80, LENGTH = 0x50
	UNUSED_RODATA_FLASH     : ORIGIN = 0x4fcc0, LENGTH = 0x340
	UNUSED_UPDATE_FUEL_LEVEL : ORIGIN = 0x12c58, LENGTH = 0xac
}

SECTIONS {
	"ReplaceROMID" 0x50022 : { LONG(0x4711a032) }

	"Rcmod common code" : {
		*(.text)
	} > MIDDLE_UNUSED_FLASH

	"[m32r-splice-into-function] Free up O2 rear channel" 0xb028 : {
		LONG(new_o2_adc_runs)
		LONG(0xb048)
	}

	"data_desc" 0x60000 : {
		*(data_desc)
	}
}
