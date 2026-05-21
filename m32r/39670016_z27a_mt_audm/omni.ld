/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE ../m32170.ld
INCLUDE ../math.ld
INCLUDE description.ld

SECTIONS {
	"ReplaceROMID" 0x222 : { LONG(0x3967a016) }
	INCLUDE ../load400.ld

	"data_desc" 0x60000 : {
		*(data_desc)
	}
}
