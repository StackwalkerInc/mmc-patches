# SPDX-License-Identifier: GPL-3.0-or-later
DEFINES += -DSMALL_DATA_AREA_BASE=0x808000

ROM_HINT = (Pajero iO 4G94 GDI stock)

SOURCES = ../../../src/templates/gdi_idle.c

ELF_OUT_FILE    = c6660015.elf
BIN_OUT_FILE    = $(OUT_DIR)/c666a015_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/c666a015_patches.xml
XML_HEADER_FILE = c6660015_header.xml
XML_OUT_FILE    = $(OUT_DIR)/c666a015.xml

include ../common.mk
