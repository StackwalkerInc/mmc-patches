# SPDX-License-Identifier: GPL-3.0-or-later
# The rich Z37A patch set is structurally separate from the rest of
# mmc-patches: it carries its own copies of `memaccess.h`, `gpio.h`,
# `fmath.h`, `maps_desc.h`, plus several per-ROM headers (memory_map.h,
# launch_control.h, etc.). The `-I./` at the front of CFLAGS (set in
# toolchain.mk) makes those local headers shadow the shared ones from
# `mmc-patches/include/`, which is the intended behaviour — the shared
# headers have moved on from the API this patch set was written
# against.
DEFINES += -DSMALL_DATA_AREA_BASE=0x808000

ROM_HINT = (Colt CZT Z37A 1.5T 5MT 2005 EDM)

# Local per-ROM C and S sources (kept here rather than in src/ because
# they're older versions of files that have evolved in mmc-patches/src/
# and would conflict if hoisted).
SOURCES = dash_display.c \
	mode_selector.c \
	boost_target_load_multi.c \
	launch_control.c \
	launch_control_data.c \
	etacs_handler_extension.c \
	knock_mil.c \
	knock_mil_data.c \
	update_low_gear_flags_and_apps_limit.c \
	gear_detector.c \
	nlts3.c \
	nlts2_data.c \
	launch_control_md_data.c \
	shift_light.c \
	shift_light_data.c

ASM_SOURCES = launch_control_md.S

ELF_OUT_FILE    = 47110032.elf
BIN_OUT_FILE    = $(OUT_DIR)/4711a032_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/4711a032_patches.xml
XML_HEADER_FILE = 47110032_header.xml
XML_OUT_FILE    = $(OUT_DIR)/4711a032.xml

include ../common.mk
