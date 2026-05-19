include ../toolchain.mk

ROM_DIR ?= ../../../roms
OUT_DIR ?= ../../../out

DEFINES += -DMACHINE_Z27AGMT \
	-DCLUTCH_INPUT_INVERTED \
	-DNLTS_MODULE_ENABLED \
	-DTEMP_AXIS_SRC_SDA=-13008 \
	-DTEMP_AXIS_TARGET_X_SDA=-13002 \
	-DTEMP_AXIS_TARGET_Y_SDA=-13000 \
	-DMAP_ENGINE_LOAD_POINTER=-12656 \
	-DASC_TO_DASH_RX_SLOT_INDEX=12 \
	-DENGINE_TO_CVT_DASH_TX_SLOT_INDEX=15 \
	-DKNOCK_CEL_MODE_CHANGE_INDICATION \
	-DCAN_ETACS_RX_SLOT=5 \
	-DSECRET_KEY0=55417 \
	-DSECRET_KEY1=65411 \
	-DSECRET_KEY2=59909 \
	-DSECRET_KEY3=52303

SOURCES = ../../src/gear_detector.c \
	../../src/gear_detector_data.c \
	precision_boost.c \
	../../src/map_base.c \
	../../src/map_base_data.c \
	../../src/start_ceremony.c \
	../../src/start_ceremony_data.c \
	../../src/colt_mt_cvt_dash_control.c \
	../../src/colt_mt_cvt_dash_control_data.c \
	../../src/asc_to_dash_rx.c \
	../../src/knock_mil_simple.c \
	../../src/knock_mil_data.c \
	../../src/gpio_outputs_hijack.c \
	../../src/revolution_limit.c \
	../../src/revolution_limit_data.c \
	../../src/nlts/nlts_simple.c \
	../../src/nlts/nlts_data_simple.c \
	../../src/load_extender_alt.c \
	../../src/injectors_alt.c \
	../../src/boost_alt_data.c \
	../../src/obd.c \
	../../src/obd_data.c \
	../../src/load400_math.c \
	../../src/etacs_handler_extension.c \
	../../src/mode_selector_v2_data.c \
	../../src/mode_selector_v2.c

# Object files keep their source-relative paths so omni.ld can reference them by path.
OBJECTS = $(SOURCES:.c=.o)

ORIGINAL_ROM    = $(ROM_DIR)/Z27AG_JDM_5MT_1860B104.bin
ROM_SHA256      = 47f9a77bae32cc3bc818f949c5a8037d66a6b0e22091f8a9bc051283b91a384c
ELF_OUT_FILE    = 3352a403.elf
BIN_OUT_FILE    = $(OUT_DIR)/3352a403_patched.bin
XML_PATCH_FILE  = $(OUT_DIR)/3352a403_patches.xml
XML_HEADER_FILE = 3352a403_header.xml
XML_OUT_FILE    = $(OUT_DIR)/3352a403.xml

.c.o:
	$(CC) $(CFLAGS) $(DEFINES) $< -c -o $@

.PHONY: all compile verify clean

# compile: build the ELF only (no ROM required — used by CI).
compile: $(ELF_OUT_FILE)

# all: compile + verify ROM + run codeinjector.
all: verify $(BIN_OUT_FILE) $(XML_OUT_FILE)

verify:
	@if [ ! -f "$(ORIGINAL_ROM)" ]; then \
		echo "ERROR: ROM not found at $(ORIGINAL_ROM)"; \
		echo "Place Z27AG_JDM_5MT_1860B104.bin in $(ROM_DIR)/"; \
		exit 1; \
	fi
	@actual=$$(shasum -a 256 "$(ORIGINAL_ROM)" | cut -d' ' -f1); \
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
