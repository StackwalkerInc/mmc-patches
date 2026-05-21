# SPDX-License-Identifier: GPL-3.0-or-later
include ../toolchain.mk

ROM_DIR ?= ../../../roms
OUT_DIR ?= ../../../out

DEFINES += \
	-DSMALL_DATA_AREA_BASE=0x808000 \
	-DNLTS_MODULE_ENABLED \
	-DTEMP_AXIS_SRC_SDA=-13066 \
	-DTEMP_AXIS_TARGET_X_SDA=-13060

SOURCES = ../../src/gpio_outputs_hijack.c \
	../../src/load1byte.c \
	../../src/knock_mil_simple.c \
	../../src/knock_mil_data.c \
	../../src/revolution_limit.c \
	../../src/revolution_limit_data.c \
	../../src/nlts/nlts_simple.c \
	../../src/nlts/nlts_data_simple.c \
	mode_selector_stubs.c

OBJECTS = $(SOURCES:.c=.o)

ORIGINAL_ROM    = $(ROM_DIR)/c7280011.bin
ROM_SHA256      = 19d694e2b527d00b5c81aa5d0a3ea71f2464354c5f91bb7be35c5e62d1e82d47
ELF_OUT_FILE    = c7280011.elf
BIN_OUT_FILE    = $(OUT_DIR)/c728a311_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/c728a311_patches.xml
XML_HEADER_FILE = c7280011_header.xml
XML_OUT_FILE    = $(OUT_DIR)/c728a311.xml

.c.o:
	$(CC) $(CFLAGS) $(DEFINES) $< -c -o $@

.PHONY: all compile verify clean

all: verify $(BIN_OUT_FILE) $(XML_OUT_FILE)

compile: $(ELF_OUT_FILE)

verify:
	@if [ ! -f "$(ORIGINAL_ROM)" ]; then \
		echo "ERROR: ROM not found at $(ORIGINAL_ROM)"; \
		echo "Place c7280011.bin (Outlander CU2W turbo Nameless-prepped) in $(ROM_DIR)/"; \
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
