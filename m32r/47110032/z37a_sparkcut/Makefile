# SPDX-License-Identifier: GPL-3.0-or-later
DEFINES += -DSMALL_DATA_AREA_BASE=0x808000

ROM_HINT = (Colt CZT Z37A 1.5T 5MT 2005 EDM)

SOURCES = spark_cut.c

ELF_OUT_FILE    = 4711a132.elf
BIN_OUT_FILE    = $(OUT_DIR)/4711a132_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/4711a132_patches.xml
XML_HEADER_FILE = 4711a132_header.xml
XML_OUT_FILE    = $(OUT_DIR)/4711a132.xml

include ../common.mk
