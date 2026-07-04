# SPDX-License-Identifier: GPL-3.0-or-later
DEFINES += \
	-DSMALL_DATA_AREA_BASE=0x808000 \
	-DNLTS_MODULE_ENABLED \
	-DTEMP_AXIS_SRC_SDA=-13066 \
	-DTEMP_AXIS_TARGET_X_SDA=-13060

ROM_HINT = (Outlander CU2W turbo Nameless-prepped)

SOURCES = ../../../src/gpio_outputs_hijack.c \
	../../../src/load1byte.c \
	../../../src/knock_mil_simple.c \
	../../../src/knock_mil_data.c \
	../../../src/revolution_limit.c \
	../../../src/revolution_limit_data.c \
	../../../src/nlts/nlts_simple.c \
	../../../src/nlts/nlts_data_simple.c \
	mode_selector_stubs.c

ELF_OUT_FILE    = c7280011.elf
BIN_OUT_FILE    = $(OUT_DIR)/c728a311_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/c728a311_patches.xml
XML_HEADER_FILE = c7280011_header.xml
XML_OUT_FILE    = $(OUT_DIR)/c728a311.xml

include ../common.mk
