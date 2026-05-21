# SPDX-License-Identifier: GPL-3.0-or-later
include ../toolchain.mk

ROM_DIR ?= ../../../roms
OUT_DIR ?= ../../../out

DEFINES += \
	-DSMALL_DATA_AREA_BASE=0x80c000 \
	-DTEMP_AXIS_SRC_SDA=-14968 \
	-DTEMP_AXIS_TARGET_X_SDA=-14962 \
	-DTEMP_AXIS_TARGET_Y_SDA=-14960

SOURCES = ../../src/boost_control_evox_sst_kiwamaru.c \
	../../src/evox_sst_multimap.c \
	../../src/evox_sst_mivec_multimap.c \
	../../src/sst_spark_vs_gear_correction.c

OBJECTS = $(SOURCES:.c=.o)

ORIGINAL_ROM    = $(ROM_DIR)/53050009.bin
ROM_SHA256      = 5b4c22abb55822c6fc2fd1b03e130c4961dffb81e107f849437bb3f0e7504a74
ELF_OUT_FILE    = 53050009.elf
BIN_OUT_FILE    = $(OUT_DIR)/5305a009_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/5305a009_patches.xml
XML_HEADER_FILE = 53050009_header.xml
XML_OUT_FILE    = $(OUT_DIR)/5305a009.xml

.c.o:
	$(CC) $(CFLAGS) $(DEFINES) $< -c -o $@

.PHONY: all compile verify clean

all: verify $(BIN_OUT_FILE) $(XML_OUT_FILE)

compile: $(ELF_OUT_FILE)

verify:
	@if [ ! -f "$(ORIGINAL_ROM)" ]; then \
		echo "ERROR: ROM not found at $(ORIGINAL_ROM)"; \
		echo "Place 53050009.bin in $(ROM_DIR)/ (the 1MB Evo X SST EDM stock image)"; \
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
