# SPDX-License-Identifier: GPL-3.0-or-later
# Bootloader-session RAM helper routines for the Colt CZT Z37A (47110032)
# CAN reflash protocol. These are never injected into the ROM image --
# FastECU uploads the compiled bytes directly to RAM during a live
# bootloader session (see docs/superpowers/specs/2026-07-11-z37a-top128k-can-reflash-design.md
# in the parent claude-hobby project). Applies regardless of which patch
# variant (z37a_mt_2005, z37a_sparkcut) is on the ROM, so this lives at the
# 47110032 level rather than under either variant directory.
#
# No ROM_DIR/OUT_DIR/codeinjector dependency here -- these binaries are
# plain flat machine code, not EcuFlash XML patches, so this Makefile does
# not include ../common.mk.
AS = m32r-elf-as
OBJCOPY = m32r-elf-objcopy

SOURCES = erase32170.S write32170.S
BINS = $(SOURCES:.S=.bin)

.PHONY: all compile check clean

all: check

compile: $(BINS)

%.elf: %.S
	$(AS) $< -o $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

# 16-bit running byte-sum, wraparound -- matches the ECU's own checksum
# validation for RAM uploads (get_crc() in
# externals/livemonitor/obdengine.cpp) and this repo's historical
# memfuncrcchecker.c. Plain od+awk, not Python: the m32r-injector-toolchain
# Docker image this runs in has no Python interpreter.
check: $(BINS)
	@ok=1; \
	for pair in "erase32170.bin:4486" "write32170.bin:4c41"; do \
		f=$${pair%%:*}; expected=$${pair##*:}; \
		actual=$$(od -An -v -tu1 "$$f" | awk '{for(i=1;i<=NF;i++) s+=$$i} END{printf "%04x", s%65536}'); \
		if [ "$$actual" != "$$expected" ]; then \
			echo "ERROR: $$f checksum $$actual != expected $$expected"; \
			ok=0; \
		else \
			echo "$$f checksum $$actual OK"; \
		fi; \
	done; \
	[ $$ok -eq 1 ]

clean:
	rm -f *.elf *.bin
