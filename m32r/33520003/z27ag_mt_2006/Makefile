# SPDX-License-Identifier: GPL-3.0-or-later
DEFINES += -DMACHINE_Z27AGMT \
	-DCLUTCH_INPUT_INVERTED \
	-DNLTS_MODULE_ENABLED \
	-DTEMP_AXIS_SRC_SDA=-13008 \
	-DTEMP_AXIS_TARGET_X_SDA=-13002 \
	-DTEMP_AXIS_TARGET_Y_SDA=-13000 \
	-DMAP_ENGINE_LOAD_POINTER=-12656 \
	-DASC_TO_DASH_RX_SLOT_INDEX=12 \
	-DENGINE_TO_CVT_DASH_TX_SLOT_INDEX=15 \
	-DKNOCK_CEL_MODE_CHANGE_INDICATION \
	-DCAN_ETACS_RX_SLOT=5 \
	-DSECRET_KEY0=55417 \
	-DSECRET_KEY1=65411 \
	-DSECRET_KEY2=59909 \
	-DSECRET_KEY3=52303

SOURCES = ../../../src/gear_detector.c \
	../../../src/gear_detector_data.c \
	precision_boost.c \
	../../../src/map_base.c \
	../../../src/map_base_data.c \
	../../../src/start_ceremony.c \
	../../../src/start_ceremony_data.c \
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
	../../../src/load_extender_alt.c \
	../../../src/injectors_alt.c \
	../../../src/boost_alt_data.c \
	../../../src/obd/vin_guard.c \
	../../../src/load400_math.c \
	../../../src/etacs_handler_extension.c \
	../../../src/mode_selector_v2_data.c \
	../../../src/mode_selector_v2.c

ELF_OUT_FILE    = 3352a403.elf
BIN_OUT_FILE    = $(OUT_DIR)/3352a403_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/3352a403_patches.xml
XML_HEADER_FILE = 3352a403_header.xml
XML_OUT_FILE    = $(OUT_DIR)/3352a403.xml

include ../common.mk
