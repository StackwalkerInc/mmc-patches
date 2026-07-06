# SPDX-License-Identifier: GPL-3.0-or-later
DEFINES += -DSMALL_DATA_AREA_BASE=0x808000 \
	-DMACHINE_Z37A_MT \
	-DCLUTCH_INPUT_INVERTED \
	-DTEMP_AXIS_SRC_SDA=-13344 \
	-DTEMP_AXIS_TARGET_X_SDA=-13338 \
	-DTEMP_AXIS_TARGET_Y_SDA=-13336 \
	-DMAP_ENGINE_LOAD_POINTER=-13008 \
	-DOVERREV_FUEL_ENRICHMENT_DISABLED

ROM_HINT = (Colt CZT Z37A 1.5T 5MT 2005 EDM)

SOURCES = ../../../src/rolling_spark_cut.c \
	../../../src/knock_mil_simple.c \
	../../../src/knock_mil_data.c \
	../../../src/gpio_outputs_hijack.c

ELF_OUT_FILE    = 4711a132.elf
BIN_OUT_FILE    = $(OUT_DIR)/4711a132_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/4711a132_patches.xml
XML_HEADER_FILE = 4711a132_header.xml
XML_OUT_FILE    = $(OUT_DIR)/4711a132.xml

include ../common.mk
