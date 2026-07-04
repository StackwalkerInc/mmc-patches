# SPDX-License-Identifier: GPL-3.0-or-later
include ../toolchain.mk

ROM_DIR ?= ../../../roms
OUT_DIR ?= ../../../out

DEFINES += -DSMALL_DATA_AREA_BASE=0x808000

SOURCES = spark_cut.c
OBJECTS = $(SOURCES:.c=.o)

DOCKER_IMAGE = ghcr.io/rcusstackwalker/m32r-injector-toolchain:latest

ORIGINAL_ROM    = $(ROM_DIR)/47110032.bin
ROM_SHA256      = c52e83d190528fc1bf63fb569d7b51b8b363688c5a708f10fb25f4432eff315b
ELF_OUT_FILE    = 47110032_sparkcut.elf
BIN_OUT_FILE    = $(OUT_DIR)/4711a032_sparkcut_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/4711a032_sparkcut_patches.xml
XML_HEADER_FILE = ../47110032_z37a_mt_2005/47110032_header.xml
XML_OUT_FILE    = $(OUT_DIR)/4711a032_sparkcut.xml

.c.o:
	$(CC) $(CFLAGS) $(DEFINES) $< -c -o $@

.PHONY: all compile verify clean docker

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

docker:
	docker run --rm \
		-v "$(CURDIR)/../..:/work" \
		-w /work/m32r/47110032_z37a_sparkcut \
		$(DOCKER_IMAGE) \
		make ROM_DIR=/work/roms OUT_DIR=/work/out

clean:
	rm -f $(OBJECTS) $(ELF_OUT_FILE)
