/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE description.ld

indicator_counter = 0x804372;

MEMORY {
	UNUSED_MEMORY_FOR_MODS : ORIGIN = 0x50000, LENGTH = 0x1000
}

SECTIONS {
	"data_desc" 0x60000 : {
		*(data_desc)
	}
	"New indication code" : {
		*(.text)
		*(.rodata)
	} > UNUSED_MEMORY_FOR_MODS

	"Inject new gear indication #1 [m32r-bl]" 0x144b4 : { LONG(get_calculated_gear_indication); }
	"Inject new gear indication #2" 0x144b8 : { LONG(0xa1bdc510); }
}
