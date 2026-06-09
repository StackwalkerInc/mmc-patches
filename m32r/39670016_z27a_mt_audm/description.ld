/* SPDX-License-Identifier: GPL-3.0-or-later */
/* load400 binding addresses for the AUDM Z27A 5MT (39670016). Different
   from the JDM Z27AG layout — base spark/load/MAF/IPW call sites all
   live at different offsets. */
calc_ipw_override_shaft_multiplication_location			= 0x33ebc;
calc_ipw_override_load_x_nominal_ipw_division_location		= 0x34656;
calc_engine_loads_override_lsv_to_load_multiplier1_location	= 0x1e51d;
calc_engine_loads_override_lsv_to_load_multiplier2_location	= 0x1e53b;
calc_engine_loads_override_lsv_to_comp_load_multiplier_location	= 0x1e556;
tomo_calc_engine_loads_override_lsv_to_load_multiplier_location	= 0x667fd;
tomo_calc_engine_loads_override_lsv_to_flow_multiplier_location	= 0x6685e;
divide_by2_maf_charge_max_base_vs_rpm_2dmap16_location		= 0x6372;
flash_base_spark_limit_reset_load_delta_positive_threshold	= 0xac4;
maf_fault_default_load_location					= 0x33f46;
calc_engine_loads_override_lsv_to_flow_multiplier_location	= 0x1e60e;
divide_by2_maf_load_high_vs_rpm_2dmap16_location		= 0x7e68;
ipw_safe_change_load_source_threshold_location			= 0x25c32;
load400_math_space						= 0x4f9a8;

/* OBD mode 0x23 (ReadMemoryByAddress) bindings — from rom-analyzer --emit-mode23
 * + raw-byte verification against 39670016.bin. */
sio0_rx_buffer				= 0x8053d8;
sio0_tx_buffer				= 0x8053ee;
sio0_tx_count				= 0x805430;
canrx12_data				= 0x805c0c;
canrx15_data				= 0x805c04;	/* canrx12_data - 8; functional-addressing RX buffer */
cantx5_data0				= 0x805c14;
canrx12_15_process			= 0x4a014;
obd_rest_handler_injection_location	= 0x60248;
canrx12_15_call_location_slot12		= 0x49dc4;	/* slot arg 2 -> canrx12_data (long bl) */
canrx12_15_call_location_slot15		= 0x49e9c;	/* slot arg 1 -> canrx15_data (short bl; word = 7e5ef000) */
