# SPDX-License-Identifier: GPL-3.0-or-later
# Minimal load400 port matching mmc-research's build.sh intent.
DEFINES += -DSMALL_DATA_AREA_BASE=0x808000
DEFINES += -DFEATURE_OBD_MODE_23 -DFEATURE_OBD_MODE_3D

SOURCES = ../../../src/load400_math.c \
	../../../src/obd/dispatch_kline.c \
	../../../src/obd/dispatch_can.c

ELF_OUT_FILE    = 39670016.elf
BIN_OUT_FILE    = $(OUT_DIR)/3967a016_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/3967a016_patches.xml
XML_HEADER_FILE = 39670016_header.xml
XML_OUT_FILE    = $(OUT_DIR)/3967a016.xml

include ../common.mk
