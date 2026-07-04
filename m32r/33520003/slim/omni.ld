/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE ../../m32170.ld
INCLUDE ../../math.ld
INCLUDE description.ld

MEMORY {
	UNUSED_MEMORY_FOR_MODS : ORIGIN = 0x68eac, LENGTH = 0x3000
	UNUSED_RAM_FOR_MODS : ORIGIN = 0x80553c, LENGTH = 0x20
}

SECTIONS {
	"ReplaceROMID" 0x226 : { LONG(0x3352A3A3) }

	"MainLoadAxesExtension#1 [m32r-ld24-r0]" 0x27af0 : { LONG(flash_new_main_spark_maps_load_axis) }
	"MainLoadAxesExtension#2 [m32r-ld24-r0]" 0x23bc4 : { LONG(flash_new_fuel_map_load_axis) }
	"MainLoadAxesExtension#3 [m32r-ld24-r0]" 0x2e034 : { LONG(flash_new_mivec_map_load_axis) }
	"MainLoadAxesExtension#4 [m32r-ld24-r0]" 0x2e03c : { LONG(flash_new_mivec_target_3dmap8) }
	"MainLoadAxesExtension#5" 0xcaf0 : { LONG(flash_new_high_octane_fuel_3dmap8) }
	"MainLoadAxesExtension#6" 0xcb10 : { LONG(flash_new_low_octane_fuel_3dmap8) }
	"MainLoadAxesExtension#7" 0xcc30 : { LONG(flash_new_spark_angle_high_octane_mivec_advance_max_3dmap8) }
	"MainLoadAxesExtension#8" 0xcc50 : { LONG(flash_new_spark_angle_high_octane_mivec_advance_min_3dmap8) }
	"MainLoadAxesExtension#9" 0xcc70 : { LONG(flash_new_spark_angle_high_octane_mivec_advance_target_3dmap8) }
	"MainLoadAxesExtension#10" 0xcc90 : { LONG(flash_new_spark_angle_low_octane_mivec_advance_max_3dmap8) }
	"MainLoadAxesExtension#11" 0xccb0 : { LONG(flash_new_spark_angle_low_octane_mivec_advance_min_3dmap8) }
	"MainLoadAxesExtension#12" 0xccd0 : { LONG(flash_new_spark_angle_low_octane_mivec_advance_target_3dmap8) }
	"MainLoadAxesExtension#13" 0xcb30 : { LONG(flash_new_warmup_retard_mivec_advance_max_3dmap8) }
	"MainLoadAxesExtension#14" 0xcb50 : { LONG(flash_new_warmup_retard_mivec_advance_min_3dmap8) }
	"MainLoadAxesExtension#15" 0xcb70 : { LONG(flash_new_warmup_retard_mivec_advance_target_3dmap8) }
	"MainLoadAxesExtension#16" 0x49a00 : { ../../../src/load_extender.o(.rodata) }

	INCLUDE ../../guard_injection.ld
	INCLUDE ../../load400.ld
	INCLUDE ../../nlts.ld


	"Extended Load Logging - MUT B6" mut_table_start + 0xb6 * 4 : { LONG(load_source_value) }
	"MAP Signal Logging - MUT B7" mut_table_start + 0xb7 * 4 : { LONG(map_avg) }
	"MAT Voltage Logging - MUT B8" mut_table_start + 0xb8 * 4 : { LONG(adc_byte_mat + 1) }
	"MAT Logging - MUT B9" mut_table_start + 0xb9 * 4 : { LONG(mat + 1) }

	"Omni#1" : {
		*(.text)
		*(.rodata)
		*(.rodata*)
		*(knock_mil_data_section)
	} > UNUSED_MEMORY_FOR_MODS


	"MAP Logging: Inject update_mat [m32r-bl]" calc_iat_call_location : { LONG(hijack_calc_iat) }
	"MAP Logging: Inject adc_convert_map [m32r-bl]" adc_convert_maf_call_location : { LONG(hijack_800hz_adc_call) }

	/*We need to disable access to one rx slot and reconfigure it to receive ETACS messages. then we need 0x1b5 transmission slot*/
	"CVT Engine to Dash message: Stubout can slots#15 rx access" 0x4915c : {
		SHORT(0x7000)
		SHORT(0x7000)
	}
	"CVT Engine to Dash message: Reconfigure can slot#15 RX->TX" 0x11cf3 : { BYTE(0x80) }
	"CVT Engine to Dash message: Reconfigure can slot#15 SID0" 0x11d03 : { BYTE(0x06) }
	"CVT Engine to Dash message: Reconfigure can slot#15 SID1" 0x11d13 : { BYTE(0x35) }
	"CVT Engine to Dash message: Reconfigure can slot#15 DLC" 0x11d53 : { BYTE(0x08) }
	"CVT Engine to Dash message: send [m32r-bl]" can0_40ms_tx_call_location : { LONG(new_can0_40ms_tx) }

	/*SID=0x239, DLC=8*/
	"CVT Dash Control. ASC to Dash message: Reconfigure can slot#12 SID0" 0x11d00 : { BYTE(0x08) }
	"CVT Dash Control. ASC to Dash message: Reconfigure can slot#12 SID1" 0x11d10 : { BYTE(0x39) }
	"CVT Dash Control. ASC to Dash message: Reconfigure can slot#12 DLC" 0x11d50 : { BYTE(0x08) }
	"CVT Dash Control. ASC to Dash message: Receive [m32r-bl]" can0_slot12_rx_update_call_location : { LONG(update_asc_to_dash_rx) }

	INCLUDE ../../knockcel_injection.ld
	INCLUDE ../../gpio_outputs_hijack.ld

	"RAM" : {
		*(COMMON)
	} > UNUSED_RAM_FOR_MODS

	"data_desc" 0x60000 : {
		*(data_desc)
	}

}
