# SPDX-License-Identifier: GPL-3.0-or-later
include ../toolchain.mk

ROM_DIR ?= ../../../roms
OUT_DIR ?= ../../../out

DEFINES += \
	-DMACHINE_EVOX_MT=1 \
	-DOVERREV_FUEL_ENRICHMENT_DISABLED \
	-DNLTS_MODULE_ENABLED \
	-DTEMP_AXIS_SRC_SDA=-14968 \
	-DTEMP_AXIS_TARGET_X_SDA=-14962 \
	-DTEMP_AXIS_TARGET_Y_SDA=-14960

SOURCES = ../../src/gpio_outputs_hijack.c \
	../../src/gear_detector.c \
	../../src/gear_detector_data.c \
	../../src/revolution_limit.c \
	../../src/revolution_limit_data.c \
	../../src/nlts/nlts.c \
	../../src/nlts/nlts_data.c \
	../../src/evox_limit_accel.c \
	../../src/boost_control_evox_mt_pergear.c \
	../../src/tephra_multimap.c \
	../../src/spark_cut.c

OBJECTS = $(SOURCES:.c=.o)

ORIGINAL_ROM    = $(ROM_DIR)/53040110.bin
ROM_SHA256      = 7b842546a7ba8c068460e97c876b5b82255c684a5c21f1f9306ee4536aeb4238
ELF_OUT_FILE    = 53040110.elf
BIN_OUT_FILE    = $(OUT_DIR)/53040110_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/53040110_patches.xml
XML_HEADER_FILE = 53040110_header.xml
XML_OUT_FILE    = $(OUT_DIR)/53040110.xml

.c.o:
	$(CC) $(CFLAGS) $(DEFINES) $< -c -o $@

.PHONY: all compile verify clean

all: verify $(BIN_OUT_FILE) $(XML_OUT_FILE)

compile: $(ELF_OUT_FILE)

verify:
	@if [ ! -f "$(ORIGINAL_ROM)" ]; then \
		echo "ERROR: ROM not found at $(ORIGINAL_ROM)"; \
		echo "Place 53040110.bin in $(ROM_DIR)/ (the raw 1MB Tephra XMOD base image, despite the .hex extension in mmc-research)"; \
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
