# SPDX-License-Identifier: GPL-3.0-or-later
DOCKER_IMAGE = ghcr.io/rcusstackwalker/m32r-injector-toolchain:latest

export ROM_DIR ?= $(CURDIR)/roms
export OUT_DIR ?= $(CURDIR)/out

ROM_DIRS = m32r/33520003_z27ag_mt_2006 \
	m32r/3352a3a3_z27ag_mt_2006 \
	m32r/35740031_z27a_cvt_2005 \
	m32r/39670016_z27a_mt_audm \
	m32r/47110032_z37a_mt_2005 \
	m32r/53040110_cz4a_mt_edm_Tephra \
	m32r/53050009_cz4a_sst_edm \
	m32r/8631B0190A_pajero_sport_at \
	m32r/b2940007_eclipse_mt_2008 \
	m32r/c6660015_pajero_io_4g94gdi \
	m32r/c728001x_cu2w_outlander_turbo

.PHONY: all compile clean docker docker-compile $(ROM_DIRS) $(ROM_DIRS:%=%-compile)

# Build patched ROM + XML for all targets (requires ROMs in roms/).
all: $(ROM_DIRS)

# Compile to ELF for all targets (no ROM needed — used by CI).
compile: $(ROM_DIRS:%=%-compile)

$(ROM_DIRS):
	$(MAKE) -C $@ ROM_DIR=$(ROM_DIR) OUT_DIR=$(OUT_DIR)

$(ROM_DIRS:%=%-compile):
	$(MAKE) -C $(@:%-compile=%) compile

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

# Build the patched ROM inside the canonical Docker image.
docker:
	docker run --rm -v "$(CURDIR):/work" -w /work $(DOCKER_IMAGE) \
		make ROM_DIR=/work/roms OUT_DIR=/work/out

# Compile only (no ROM) inside the canonical Docker image.
docker-compile:
	docker run --rm -v "$(CURDIR):/work" -w /work $(DOCKER_IMAGE) make compile

clean:
	for d in $(ROM_DIRS); do $(MAKE) -C $$d clean; done
	rm -rf $(OUT_DIR)
