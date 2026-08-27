/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE ../../m32170.ld
INCLUDE description.ld

/* Free-space regions confirmed available on 47110032 by z37a_mt_2005's
   own omni.ld (same physical ROM, same free-space survey). */
MEMORY {
	IDLE_CHECK : ORIGIN = 0x3c730, LENGTH = 0x600
	MDP_EVAP_EXT_CHECK : ORIGIN = 0x46738, LENGTH = 0x730
	LAST_UNUSED_FLASH : ORIGIN = 0x5fc74, LENGTH = 0x38a
	MIDDLE_UNUSED_FLASH : ORIGIN = 0x4fcbc, LENGTH = 0x344
	UNUSED_RODATA_FLASH : ORIGIN = 0x4fcc0, LENGTH = 0x340
	UNUSED_RAM_FOR_MODS : ORIGIN = 0x804d22, LENGTH = 0x8
	TOP_EXT : ORIGIN = 0x60010, LENGTH = 0x1FFF0
}

SECTIONS {
	"ReplaceROMID" 0x50022 : { LONG(0x4711A132) }


	"Nopout idle_check call to use IDLE_CHECK memory area" 0x33c80 : {
		SHORT(0x7000)
		SHORT(0x7000)
	}

	"Common Code/Data" : {
		*(.text)
		*(EXCLUDE_FILE(*extended_maps.o) .rodata)
	} > IDLE_CHECK

	INCLUDE ../../knockcel_injection.ld
	INCLUDE ../../rolling_spark_cut_injection.ld
	INCLUDE ../../gpio_outputs_hijack.ld

	/* TODO: confirm via rom-analyzer — call site for update_current_gear() */

	"RAM" : {
		*(COMMON)
	} > UNUSED_RAM_FOR_MODS

	"Top Region Magic" 0x60000 : { LONG(0x5a37a001) }

	"Extended Maps" : {
		extended_maps.o(.rodata)
		extended_maps.o(.rodata*)
	} > TOP_EXT

	"Extended Fuel Load Axis [m32r-ld24-r0]"    0x176f8 : { LONG(flash_new_fuel_load_axis) }
	"Extended Spark Load Axis 17a [m32r-ld24-r0]" 0x1b36c : { LONG(flash_new_spark_load_axis_17) }
	"Extended Spark Load Axis 17b [m32r-ld24-r0]" 0x1b464 : { LONG(flash_new_spark_load_axis_17) }
	"Extended Spark Load Axis 12a [m32r-ld24-r0]" 0x1b398 : { LONG(flash_new_spark_load_axis_12) }
	"Extended Spark Load Axis 12b [m32r-ld24-r0]" 0x1b3f4 : { LONG(flash_new_spark_load_axis_12) }
	"Extended MIVEC Load Axis [m32r-ld24-r0]"     0x4d73c : { LONG(flash_new_mivec_load_axis) }

	"Alt Fuel Hi #1 [m32r-ld24-r0]" 0x17740 : { LONG(flash_new_fuel_hi_octane_multimap) }
	"Alt Fuel Hi #2 [m32r-ld24-r0]" 0x1774c : { LONG(flash_new_fuel_hi_octane_multimap) }
	"Alt Fuel Lo #1 [m32r-ld24-r0]" 0x1770c : { LONG(flash_new_fuel_lo_octane_multimap) }
	"Alt Fuel Lo #2 [m32r-ld24-r0]" 0x17718 : { LONG(flash_new_fuel_lo_octane_multimap) }

	"Alt Spark 4f9fc [m32r-ld24-r0]"    0x1b408 : { LONG(flash_new_spark_4f9fc_multimap) }
	"Alt Spark 4fa1c [m32r-ld24-r0]"    0x1b3a0 : { LONG(flash_new_spark_4fa1c_multimap) }
	"Alt Spark 4fa3c #1 [m32r-ld24-r0]" 0x1b3ac : { LONG(flash_new_spark_4fa3c_multimap) }
	"Alt Spark 4fa3c #2 [m32r-ld24-r0]" 0x1b3fc : { LONG(flash_new_spark_4fa3c_multimap) }
	"Alt Spark 4fafc [m32r-ld24-r0]"    0x1b4b0 : { LONG(flash_new_spark_4fafc_multimap) }
	"Alt Spark 4fb1c [m32r-ld24-r0]"    0x1b478 : { LONG(flash_new_spark_4fb1c_multimap) }
	"Alt Spark 4fb3c #1 [m32r-ld24-r0]" 0x1b484 : { LONG(flash_new_spark_4fb3c_multimap) }
	"Alt Spark 4fb3c #2 [m32r-ld24-r0]" 0x1b4a4 : { LONG(flash_new_spark_4fb3c_multimap) }
	"Alt Spark 4fb5c [m32r-ld24-r0]"    0x1b3e8 : { LONG(flash_new_spark_4fb5c_multimap) }
	"Alt Spark 4fb7c [m32r-ld24-r0]"    0x1b380 : { LONG(flash_new_spark_4fb7c_multimap) }
	"Alt Spark 4fb9c #1 [m32r-ld24-r0]" 0x1b38c : { LONG(flash_new_spark_4fb9c_multimap) }
	"Alt Spark 4fb9c #2 [m32r-ld24-r0]" 0x1b3dc : { LONG(flash_new_spark_4fb9c_multimap) }

	"Alt MIVEC Target [m32r-ld24-r0]"        0x4d744 : { LONG(flash_new_mivec_target_multimap) }
	"Alt MIVEC Target multimap [m32r-bl]"    0x4d748 : { LONG(multimap8u16) }

	/* Task 4: drive the stock mode_idx from the ETACS position-lights
	   signal, so the alt map set (Task 3) is actually selectable. */
	"Mode Selector: activate selection [m32r-bl]" 0x10aa0 : {
		LONG(new_adc_convert_mode_input_z37a)
	}
	"Mode Selector: ETACS position lights handler" flash_can_rx_handlers_1 : {
		LONG(can_rx_etacs_extended_handler)
	}

	/* Task 5: park the tach at a per-mode RPM over CAN for the length of
	   the mode-change CEL flash window. Replaces the bl at 0x4e1bc
	   (stock target 0x2ba70 = can0_update_bus_state_and_data, itself
	   exactly "can0_update_bus_state(); can0_update_tx_data();" with no
	   argument -- confirmed in description.ld). */
	"Dash: mode RPM indication [m32r-bl]" 0x4e1bc : {
		LONG(can_topcall_replacement_z37a)
	}

	"data_desc" 0 : { *(data_desc) }
	/* codeinjector matches data_seed by section NAME only (main.rs pass 1/2
	   `match section.name()`) and never injects its bytes at its ELF
	   address, so any non-overlapping placeholder address works here; 0
	   would collide with data_desc's own LMA range (a hard ld error, not
	   just a warning), so this uses a distinct one instead. */
	"data_seed" 0x1000 : { *(data_seed) }
}
