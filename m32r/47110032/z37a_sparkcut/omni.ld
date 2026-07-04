/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE ../../m32170.ld
INCLUDE description.ld

MEMORY {
	SPARKCUT : ORIGIN = 0x5fed0, LENGTH = 0x1130	/* 0x60000 - 0x5fed0 */
}

SECTIONS {
	"ReplaceROMID" 0x50022 : { LONG(0x4711A132) }

	"Spark Cut Params" 0x5fed0 : {
		spark_cut.o(.spark_cut_params)
	} > SPARKCUT

	"Spark Cut Code" 0x5ff10 : {
		spark_cut.o(.text)
	} > SPARKCUT

	"Spark Cut [m32r-bl]" 0x1b2cc : { LONG(spark_cut) }

	"data_desc" 0 : { *(data_desc) }
}
