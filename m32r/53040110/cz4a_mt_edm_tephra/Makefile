# SPDX-License-Identifier: GPL-3.0-or-later
DEFINES += \
	-DMACHINE_EVOX_MT=1 \
	-DOVERREV_FUEL_ENRICHMENT_DISABLED \
	-DNLTS_MODULE_ENABLED \
	-DTEMP_AXIS_SRC_SDA=-14968 \
	-DTEMP_AXIS_TARGET_X_SDA=-14962 \
	-DTEMP_AXIS_TARGET_Y_SDA=-14960

ROM_HINT = (the raw 1MB Tephra XMOD base image, despite the .hex extension in mmc-research)

SOURCES = ../../../src/gpio_outputs_hijack.c \
	../../../src/gear_detector.c \
	../../../src/gear_detector_data.c \
	../../../src/revolution_limit.c \
	../../../src/revolution_limit_data.c \
	../../../src/nlts/nlts.c \
	../../../src/nlts/nlts_data.c \
	../../../src/evox_limit_accel.c \
	../../../src/boost_control_evox_mt_pergear.c \
	../../../src/tephra_multimap.c \
	../../../src/spark_cut.c

ELF_OUT_FILE    = 53040110.elf
BIN_OUT_FILE    = $(OUT_DIR)/53040110_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/53040110_patches.xml
XML_HEADER_FILE = 53040110_header.xml
XML_OUT_FILE    = $(OUT_DIR)/53040110.xml

include ../common.mk
