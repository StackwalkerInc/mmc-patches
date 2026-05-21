/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE ../math.ld
INCLUDE description.ld
INCLUDE mut_table_variables.ld

/* Initial port scope: ReplaceROMID + MUTII enable + the MDP-value fix
   + ecu_options metadata. mmc-research's omni.ld also includes
   load400_2banks_no_tomo.ld / knockcel_injection.ld /
   boost_through_purge_pwm.ld / a `Replace boost_control stub` patch,
   but the C source (main_map_calcs.c) it expected references macros
   (MAP_AXIS_SRC_SDA, MAP_AXIS_DST_SDA) and symbols (boost_control,
   flash_map_limits_load_3dmap16) that have no in-tree definition;
   mmc-research's build looks incomplete for this ROM. Those sections
   stay deferred until the source side is reconciled. */

MEMORY {
	UNUSED_MEMORY_FOR_MODS : ORIGIN = 0x4d53c, LENGTH = 0x1000
}

SECTIONS {
	"ReplaceROMID" 0x8226 : { LONG(0xb294a007) }

	"Enable MUTII protocol" 0x5ed1c : {
		SHORT(0x1089)
		SHORT(0x7000)
		SHORT(0x5050)
	}

	"CommonCode#0" : {
		*(.text)
		*(.rodata)
	} > UNUSED_MEMORY_FOR_MODS

	"data_desc" 0x80000 : {
		*(data_desc)
	}

	/* This fixes P0108 but causes P0106; included verbatim from mmc-research. */
	"Fix Manifold Differential Pressure Value to 205" 0x17d28 : {
		LONG(0x90f000cd)
		LONG(0xa02dcf18)
		LONG(0x70007000)
	}
}
