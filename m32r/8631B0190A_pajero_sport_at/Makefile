# SPDX-License-Identifier: GPL-3.0-or-later
include ../toolchain.mk

ROM_DIR ?= ../../../roms
OUT_DIR ?= ../../../out

SOURCES = ../../src/templates/at_shift.c \
	../../src/at/pajero_manual_indicator.c \
	../../src/at/pajero_manual_indicator_data.c

OBJECTS = $(SOURCES:.c=.o)

ORIGINAL_ROM    = $(ROM_DIR)/8631B0190A.bin
ROM_SHA256      = 6b7b93db288f4b06fe04de1113447b2727738b2cb327f3085abe7ac8fe42c571
ELF_OUT_FILE    = 8631B0190A.elf
BIN_OUT_FILE    = $(OUT_DIR)/8631B0190A_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/8631B0190A_patches.xml
XML_HEADER_FILE = 8631B0190A_header.xml
XML_OUT_FILE    = $(OUT_DIR)/8631B0190A.xml

.c.o:
	$(CC) $(CFLAGS) $(DEFINES) $< -c -o $@

.PHONY: all compile verify clean

all: verify $(BIN_OUT_FILE) $(XML_OUT_FILE)

compile: $(ELF_OUT_FILE)

verify:
	@if [ ! -f "$(ORIGINAL_ROM)" ]; then \
		echo "ERROR: ROM not found at $(ORIGINAL_ROM)"; \
		echo "Place 8631B0190A.bin (Pajero Sport diesel AT ECU) in $(ROM_DIR)/"; \
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
