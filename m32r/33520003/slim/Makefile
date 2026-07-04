# SPDX-License-Identifier: GPL-3.0-or-later
# Slimmer companion patch set for the same Z27AG MT 2006 stock ROM as
# z27ag_mt_2006. Same machine #defines so the shared sources compile
# identically.
DEFINES += -DMACHINE_Z27AGMT \
	-DCLUTCH_INPUT_INVERTED \
	-DNLTS_MODULE_ENABLED \
	-DTEMP_AXIS_SRC_SDA=-13008 \
	-DTEMP_AXIS_TARGET_X_SDA=-13002 \
	-DTEMP_AXIS_TARGET_Y_SDA=-13000 \
	-DMAP_ENGINE_LOAD_POINTER=-12656 \
	-DASC_TO_DASH_RX_SLOT_INDEX=12 \
	-DENGINE_TO_CVT_DASH_TX_SLOT_INDEX=15 \
	-DSECRET_KEY0=65411 \
	-DSECRET_KEY1=55417 \
	-DSECRET_KEY2=52303 \
	-DSECRET_KEY3=59909

SOURCES = ../../../src/gear_detector.c \
	../../../src/gear_detector_data.c \
	../../../src/map_base.c \
	../../../src/map_base_data.c \
	../../../src/colt_mt_cvt_dash_control.c \
	../../../src/colt_mt_cvt_dash_control_data.c \
	../../../src/asc_to_dash_rx.c \
	../../../src/knock_mil_simple.c \
	../../../src/knock_mil_data.c \
	../../../src/gpio_outputs_hijack.c \
	../../../src/revolution_limit.c \
	../../../src/revolution_limit_data.c \
	../../../src/nlts/nlts_simple.c \
	../../../src/nlts/nlts_data_simple.c \
	../../../src/load_extender.c \
	../../../src/obd/vin_guard.c \
	../../../src/load400_math.c \
	mode_selector_stubs.c

ELF_OUT_FILE    = 3352a3a3.elf
BIN_OUT_FILE    = $(OUT_DIR)/3352a3a3_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/3352a3a3_patches.xml
XML_HEADER_FILE = 3352a3a3_header.xml
XML_OUT_FILE    = $(OUT_DIR)/3352a3a3.xml

include ../common.mk
