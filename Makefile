# Top-level Makefile — builds the codeinjector tool then runs all ROM targets.
# Use ROM_DIR to point at the directory containing your stock ROM files.
# Example: make ROM_DIR=/path/to/roms z27ag

export ROM_DIR ?= $(CURDIR)/roms
export OUT_DIR ?= $(CURDIR)/out

CODEINJECTOR_BIN = tools/codeinjector/codeinjector

.PHONY: all z27ag codeinjector clean

all: z27ag

codeinjector: $(CODEINJECTOR_BIN)

$(CODEINJECTOR_BIN):
	$(MAKE) -C tools/codeinjector

z27ag: $(CODEINJECTOR_BIN) $(OUT_DIR)
	$(MAKE) -C m32r/33520003_z27ag_mt_2006 ROM_DIR=$(ROM_DIR) OUT_DIR=$(OUT_DIR)

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

clean:
	$(MAKE) -C tools/codeinjector clean
	$(MAKE) -C m32r/33520003_z27ag_mt_2006 clean
	rm -rf $(OUT_DIR)
