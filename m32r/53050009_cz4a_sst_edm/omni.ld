/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE description.ld
INCLUDE ../math.ld

MEMORY {
	UNUSED_MEMORY_FOR_MODS : ORIGIN = 0xa4000, LENGTH = 0x4000
}

SECTIONS {
	"ReplaceROMID" 0x5002c : { BYTE(0xa0) }
	"NewSSTBoost#1 [m32r-bl]" 0x9e320 : { LONG(new_update_boost_target_load) }
	"NewSSTBoost#2 [m32r-bl]" 0x9e324 : { LONG(new_calc_wastegate_reactive_duty) }

	"Enable Gear Dependant Ignition Correction [m32r-bl]" 0x2092c : { LONG(sst_spark_vs_gear_correction) }

	"NewIntakeMIVEC#1 [m32r-ld24-r0]" 0xa35bc : { LONG(flash_intake_mivec_targets) }
	"NewIntakeMIVEC#2 [m32r-bl]" 0xa35c0 : { LONG(sst_multimap8u16) }

	"NewMAPLoad#1 [m32r-ld24-r0]" 0x17e2c : { LONG(flash_mdp_loads) }
	"NewMAPLoad#2 [m32r-bl]" 0x17e30 : { LONG(sst_multimapu16) }

	"CommonCode#0" : {
		*(.text)
		*(.rodata)
	} > UNUSED_MEMORY_FOR_MODS

	"data_desc" 0x100000 : {
		*(data_desc)
	}
	"Enable K-Line MUT Protocol" 0x40220 : {
		SHORT(0x1089)
		SHORT(0x5050)
		SHORT(0x0090)
	}
}
