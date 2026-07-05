/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE ../../m32170.ld
INCLUDE description.ld

/* Free-space regions confirmed available on 47110032 by z37a_mt_2005's
   own omni.ld (same physical ROM, same free-space survey). */
MEMORY {
	IDLE_CHECK : ORIGIN = 0x3c730, LENGTH = 0x600
	MDP_EVAP_EXT_CHECK : ORIGIN = 0x46738, LENGTH = 0x730
	LAST_UNUSED_FLASH : ORIGIN = 0x5fc74, LENGTH = 0x38a
	MIDDLE_UNUSED_FLASH : ORIGIN = 0x4fcbc, LENGTH = 0x344
	UNUSED_RODATA_FLASH : ORIGIN = 0x4fcc0, LENGTH = 0x340
	UNUSED_RAM_FOR_MODS : ORIGIN = 0x80d000, LENGTH = 0x20
}

SECTIONS {
	"ReplaceROMID" 0x50022 : { LONG(0x4711A132) }

	"Gear Detector Code" : {
		../../../src/gear_detector.o(.text)
		../../../src/gear_detector_data.o(.text)
		../../../src/gear_detector_data.o(.rodata)
	} > IDLE_CHECK

	/* TODO: confirm via rom-analyzer — call site for update_current_gear() */

	"RAM" : {
		*(COMMON)
	} > UNUSED_RAM_FOR_MODS

	"data_desc" 0 : { *(data_desc) }
}
