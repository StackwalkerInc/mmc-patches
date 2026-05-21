# SPDX-License-Identifier: GPL-3.0-or-later
include ../toolchain.mk

ROM_DIR ?= ../../../roms
OUT_DIR ?= ../../../out

DEFINES += -DSMALL_DATA_AREA_BASE=0x808000

SOURCES = ../../src/templates/gdi_idle.c

OBJECTS = $(SOURCES:.c=.o)

ORIGINAL_ROM    = $(ROM_DIR)/c6660015.bin
ROM_SHA256      = 0a188a561e30bd1462f7901a36f15e22d0604c8ebddcc592d562dffa87d519f4
ELF_OUT_FILE    = c6660015.elf
BIN_OUT_FILE    = $(OUT_DIR)/c666a015_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/c666a015_patches.xml
XML_HEADER_FILE = c6660015_header.xml
XML_OUT_FILE    = $(OUT_DIR)/c666a015.xml

.c.o:
	$(CC) $(CFLAGS) $(DEFINES) $< -c -o $@

.PHONY: all compile verify clean

all: verify $(BIN_OUT_FILE) $(XML_OUT_FILE)

compile: $(ELF_OUT_FILE)

verify:
	@if [ ! -f "$(ORIGINAL_ROM)" ]; then \
		echo "ERROR: ROM not found at $(ORIGINAL_ROM)"; \
		echo "Place c6660015.bin (Pajero iO 4G94 GDI stock) in $(ROM_DIR)/"; \
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
