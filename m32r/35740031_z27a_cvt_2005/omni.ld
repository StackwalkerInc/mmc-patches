/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE description.ld

SECTIONS {
	"data_desc" 0x60000 : {
		*(data_desc)
	}
}
