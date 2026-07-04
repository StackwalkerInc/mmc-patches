/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE description.ld

SECTIONS {
	"ReplaceROMID" 0x222 : { LONG(0xc666a015) }

	"data_desc" 0x60000 : {
		*(data_desc)
	}
}
