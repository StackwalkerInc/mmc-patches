# SPDX-License-Identifier: GPL-3.0-or-later
include ../toolchain.mk

ROM_DIR ?= ../../../roms
OUT_DIR ?= ../../../out

# The rich Z37A patch set is structurally separate from the rest of
# mmc-patches: it carries its own copies of `memaccess.h`, `gpio.h`,
# `fmath.h`, `maps_desc.h`, plus several per-ROM headers (memory_map.h,
# launch_control.h, etc.). The `-I./` at the front of CFLAGS (set in
# toolchain.mk) makes those local headers shadow the shared ones from
# `mmc-patches/include/`, which is the intended behaviour — the shared
# headers have moved on from the API this patch set was written
# against.
DEFINES += -DSMALL_DATA_AREA_BASE=0x808000

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

OBJECTS = $(SOURCES:.c=.o) $(ASM_SOURCES:.S=.o)

ORIGINAL_ROM    = $(ROM_DIR)/47110032.bin
ROM_SHA256      = c52e83d190528fc1bf63fb569d7b51b8b363688c5a708f10fb25f4432eff315b
ELF_OUT_FILE    = 47110032.elf
BIN_OUT_FILE    = $(OUT_DIR)/4711a032_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/4711a032_patches.xml
XML_HEADER_FILE = 47110032_header.xml
XML_OUT_FILE    = $(OUT_DIR)/4711a032.xml

.c.o:
	$(CC) $(CFLAGS) $(DEFINES) $< -c -o $@

.S.o:
	$(CC) $(CFLAGS) $(DEFINES) $< -c -o $@

.PHONY: all compile verify clean

all: verify $(BIN_OUT_FILE) $(XML_OUT_FILE)

compile: $(ELF_OUT_FILE)

verify:
	@if [ ! -f "$(ORIGINAL_ROM)" ]; then \
		echo "ERROR: ROM not found at $(ORIGINAL_ROM)"; \
		echo "Place 47110032.bin (Colt CZT Z37A 1.5T 5MT 2005 EDM) in $(ROM_DIR)/"; \
		exit 1; \
	fi
	@actual=$$(sha256sum "$(ORIGINAL_ROM)" 2>/dev/null || shasum -a 256 "$(ORIGINAL_ROM)"); \
	actual=$$(echo "$$actual" | cut -d' ' -f1); \
	if [ "$$actual" != "$(ROM_SHA256)" ]; then \
		echo "ERROR: ROM SHA-256 mismatch"; \
		echo "  expected: $(ROM_SHA256)"; \
		echo "  got:      $$actual"; \
		exit 1; \
	fi
	@echo "ROM verified: $(ORIGINAL_ROM)"

$(ELF_OUT_FILE): $(OBJECTS)
	$(LD) $(LFLAGS) $(OBJECTS) -o $@

$(BIN_OUT_FILE): $(ELF_OUT_FILE)
	mkdir -p $(OUT_DIR)
	$(CODEINJECTOR) mmc-m32r $(ORIGINAL_ROM) $(ELF_OUT_FILE) $(BIN_OUT_FILE) > $(XML_PATCH_FILE)

$(XML_OUT_FILE): $(BIN_OUT_FILE)
	printf '<rom>\n' > $(XML_OUT_FILE) && \
	cat $(XML_HEADER_FILE) >> $(XML_OUT_FILE) && \
	cat $(XML_PATCH_FILE) >> $(XML_OUT_FILE) && \
	printf '</rom>\n' >> $(XML_OUT_FILE)

clean:
	rm -f $(OBJECTS) $(ELF_OUT_FILE)
