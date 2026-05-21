# SPDX-License-Identifier: GPL-3.0-or-later
include ../toolchain.mk

ROM_DIR ?= ../../../roms
OUT_DIR ?= ../../../out

DEFINES += \
	-DSMALL_DATA_AREA_BASE=0x808000 \
	-DTEMP_AXIS_SRC_SDA=-12854 \
	-DTEMP_AXIS_TARGET_X_SDA=-12846 \
	-DTEMP_AXIS_TARGET_Y_SDA=-12844 \
	-DMAP_RPM_AXIS_SRC=-12472 \
	-DMAP_RPM_AXIS_DST=-12472

SOURCES = ../../src/templates/ecu_options.c

OBJECTS = $(SOURCES:.c=.o)

ORIGINAL_ROM    = $(ROM_DIR)/b2940007.bin
ROM_SHA256      = d6d62ef0978e2ea8ca99eb506b87fc64690b55cdf5f31f356427e358e87953ec
ELF_OUT_FILE    = b2940007.elf
BIN_OUT_FILE    = $(OUT_DIR)/b294a007_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/b294a007_patches.xml
XML_HEADER_FILE = b2940007_header.xml
XML_OUT_FILE    = $(OUT_DIR)/b294a007.xml

.c.o:
	$(CC) $(CFLAGS) $(DEFINES) $< -c -o $@

.PHONY: all compile verify clean

all: verify $(BIN_OUT_FILE) $(XML_OUT_FILE)

compile: $(ELF_OUT_FILE)

verify:
	@if [ ! -f "$(ORIGINAL_ROM)" ]; then \
		echo "ERROR: ROM not found at $(ORIGINAL_ROM)"; \
		echo "Place b2940007.bin (Eclipse 4G 4G69 5MT 2008 USDM) in $(ROM_DIR)/"; \
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
