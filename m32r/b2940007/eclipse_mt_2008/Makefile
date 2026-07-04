# SPDX-License-Identifier: GPL-3.0-or-later
DEFINES += \
	-DSMALL_DATA_AREA_BASE=0x808000 \
	-DTEMP_AXIS_SRC_SDA=-12854 \
	-DTEMP_AXIS_TARGET_X_SDA=-12846 \
	-DTEMP_AXIS_TARGET_Y_SDA=-12844 \
	-DMAP_RPM_AXIS_SRC=-12472 \
	-DMAP_RPM_AXIS_DST=-12472

ROM_HINT = (Eclipse 4G 4G69 5MT 2008 USDM)

SOURCES = ../../../src/templates/ecu_options.c

ELF_OUT_FILE    = b2940007.elf
BIN_OUT_FILE    = $(OUT_DIR)/b294a007_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/b294a007_patches.xml
XML_HEADER_FILE = b2940007_header.xml
XML_OUT_FILE    = $(OUT_DIR)/b294a007.xml

include ../common.mk
