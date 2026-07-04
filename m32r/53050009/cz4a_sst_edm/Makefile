# SPDX-License-Identifier: GPL-3.0-or-later
DEFINES += \
	-DSMALL_DATA_AREA_BASE=0x80c000 \
	-DTEMP_AXIS_SRC_SDA=-14968 \
	-DTEMP_AXIS_TARGET_X_SDA=-14962 \
	-DTEMP_AXIS_TARGET_Y_SDA=-14960

ROM_HINT = (the 1MB Evo X SST EDM stock image)

SOURCES = ../../../src/boost_control_evox_sst_kiwamaru.c \
	../../../src/evox_sst_multimap.c \
	../../../src/evox_sst_mivec_multimap.c \
	../../../src/sst_spark_vs_gear_correction.c

ELF_OUT_FILE    = 53050009.elf
BIN_OUT_FILE    = $(OUT_DIR)/5305a009_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/5305a009_patches.xml
XML_HEADER_FILE = 53050009_header.xml
XML_OUT_FILE    = $(OUT_DIR)/5305a009.xml

include ../common.mk
