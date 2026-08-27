// SPDX-License-Identifier: GPL-3.0-or-later
/* Extended load axes and a second (alt) map set for 47110032, placed in the
   top 128KB. Bodies and structural fields are filled by codeinjector from
   the stock ROM at build time -- see DECLARE_*_SEEDED in maps_desc.h. Only
   names and dimensions live here. */
#include <stdint.h>
#include <maps_decl.h>

/* Seed sources, bound in description.ld. */
extern const uint8_t flash_fuel_load_axis_stock[];
extern const uint8_t flash_spark_load_axis_17_stock[];
extern const uint8_t flash_spark_load_axis_12_stock[];
extern const uint8_t flash_mivec_load_axis_stock[];

extern const uint8_t flash_fuel_hi_octane_stock[];
extern const uint8_t flash_fuel_lo_octane_stock[];
extern const uint8_t flash_spark_4f9fc_stock[];
extern const uint8_t flash_spark_4fa1c_stock[];
extern const uint8_t flash_spark_4fa3c_stock[];
extern const uint8_t flash_spark_4fafc_stock[];
extern const uint8_t flash_spark_4fb1c_stock[];
extern const uint8_t flash_spark_4fb3c_stock[];
extern const uint8_t flash_spark_4fb5c_stock[];
extern const uint8_t flash_spark_4fb7c_stock[];
extern const uint8_t flash_spark_4fb9c_stock[];
extern const uint8_t flash_mivec_target_stock[];

/* Stock 16 -> 21, 17 -> 22, 12 -> 17, 15 -> 20. */
#define FUEL_LOAD_N 21
#define SPARK17_LOAD_N 22
#define SPARK12_LOAD_N 17
#define MIVEC_LOAD_N 20

/* X (RPM) sizes are unchanged from stock. */
#define FUEL_RPM_N 14
#define SPARK_RPM_N 16
#define MIVEC_RPM_N 16

DECLARE_AXIS_DESC_EX(flash_fuel_map_rpm_axis, "RPM", "RPM");
DECLARE_AXIS_DESC_EX(flash_main_spark_maps_rpm_axis, "RPM", "RPM");
DECLARE_AXIS_DESC_EX(flash_mivec_target_rpm_axis, "RPM", "RPM");

DECLARE_AXIS_SEEDED(flash_new_fuel_load_axis, FUEL_LOAD_N, "New Fuel Load Axis", "Load", flash_fuel_load_axis_stock);
DECLARE_AXIS_SEEDED(flash_new_spark_load_axis_17, SPARK17_LOAD_N, "New Spark Load Axis", "Load",
                    flash_spark_load_axis_17_stock);
DECLARE_AXIS_SEEDED(flash_new_spark_load_axis_12, SPARK12_LOAD_N, "New Spark Target Load Axis", "Load",
                    flash_spark_load_axis_12_stock);
DECLARE_AXIS_SEEDED(flash_new_mivec_load_axis, MIVEC_LOAD_N, "New MIVEC Load Axis", "Load",
                    flash_mivec_load_axis_stock);

/* One family = {main, alt} + an 8-entry array: slot 0 main, slots 1-7 alt.
 *
 * The two DECLARE_3DMAP8_SEEDED invocations are wrapped in #pragma pack(1)
 * (via _Pragma, since a directive can't appear directly in a macro body).
 * DECLARE_3DMAP8 (maps_decl.h, shared and not touched by this task) lays
 * out { u8 type; u8 offset; i16 xsrc; i16 ysrc; u8 xsize; u8 data[xn*yn]; },
 * whose 7-byte header is odd, so with every RPM axis here even (14/16) the
 * body is always even too and the natural 2-byte struct alignment (from the
 * i16 members) rounds the whole thing up by one trailing pad byte -- e.g.
 * the MIVEC family's 320-byte body makes an unpacked struct 328 bytes, not
 * 327. codeinjector's seed.rs computes each seeded table's size straight
 * from the ELF symbol's st_size and requires it to be exactly
 * MAP3D8_HEADER + stock_xs*n (seed.rs:350-354) -- for every even stock_xs
 * that pad byte makes st_size fail that check outright ("... has size N,
 * which is not 7 + stock_xs*n"), independent of which particular family.
 * Packing removes the pad so st_size lands on the exact formula, and
 * matches how the stock ROM's own hand-laid tables are packed with no
 * padding in the first place. Scoped to just these two lines so the
 * `_multimap` pointer array right below keeps its normal 4-byte alignment.
 */
#define DECLARE_FAMILY(sym, xn, yn, cat, uname, scaling, xaxis, yaxis, stock, stock_yaxis)                             \
	_Pragma("pack(push, 1)")                                                                                           \
	    DECLARE_3DMAP8_SEEDED(sym##_main, xn, yn, cat, uname " - Main", scaling, xaxis, yaxis, stock, stock_yaxis);    \
	DECLARE_3DMAP8_SEEDED(sym##_alt, xn, yn, cat, uname " - Alt", scaling, xaxis, yaxis, stock, stock_yaxis);          \
	_Pragma("pack(pop)") const void *const sym##_multimap[8] = {&sym##_main, &sym##_alt, &sym##_alt, &sym##_alt,       \
	                                                            &sym##_alt,  &sym##_alt, &sym##_alt, &sym##_alt}

#define FUEL_FAMILY(sym, uname, stock)                                                                                 \
	DECLARE_FAMILY(sym, FUEL_RPM_N, FUEL_LOAD_N, "LoadExtendedMaps", uname, "AFR", "DDflash_new_fuel_load_axis",       \
	               "DXflash_fuel_map_rpm_axis", stock, flash_fuel_load_axis_stock)

#define SPARK17_FAMILY(sym, uname, stock)                                                                              \
	DECLARE_FAMILY(sym, SPARK_RPM_N, SPARK17_LOAD_N, "LoadExtendedMaps", uname, "Timing",                              \
	               "DDflash_new_spark_load_axis_17", "DXflash_main_spark_maps_rpm_axis", stock,                        \
	               flash_spark_load_axis_17_stock)

#define SPARK12_FAMILY(sym, uname, stock)                                                                              \
	DECLARE_FAMILY(sym, SPARK_RPM_N, SPARK12_LOAD_N, "LoadExtendedMaps", uname, "Timing",                              \
	               "DDflash_new_spark_load_axis_12", "DXflash_main_spark_maps_rpm_axis", stock,                        \
	               flash_spark_load_axis_12_stock)

FUEL_FAMILY(flash_new_fuel_hi_octane, "Target AFR - High Octane", flash_fuel_hi_octane_stock);
FUEL_FAMILY(flash_new_fuel_lo_octane, "Target AFR - Low Octane", flash_fuel_lo_octane_stock);

SPARK12_FAMILY(flash_new_spark_4f9fc, "Spark 4f9fc", flash_spark_4f9fc_stock);
SPARK12_FAMILY(flash_new_spark_4fa1c, "Spark 4fa1c", flash_spark_4fa1c_stock);
SPARK12_FAMILY(flash_new_spark_4fa3c, "Spark 4fa3c", flash_spark_4fa3c_stock);

SPARK17_FAMILY(flash_new_spark_4fafc, "Spark 4fafc", flash_spark_4fafc_stock);
SPARK17_FAMILY(flash_new_spark_4fb1c, "Spark 4fb1c", flash_spark_4fb1c_stock);
SPARK17_FAMILY(flash_new_spark_4fb3c, "Spark 4fb3c", flash_spark_4fb3c_stock);
SPARK17_FAMILY(flash_new_spark_4fb5c, "Spark 4fb5c", flash_spark_4fb5c_stock);
SPARK17_FAMILY(flash_new_spark_4fb7c, "Spark 4fb7c", flash_spark_4fb7c_stock);
SPARK17_FAMILY(flash_new_spark_4fb9c, "Spark 4fb9c", flash_spark_4fb9c_stock);

DECLARE_FAMILY(flash_new_mivec_target, MIVEC_RPM_N, MIVEC_LOAD_N, "LoadExtendedMaps", "MIVEC Target", "Angle",
               "DDflash_new_mivec_load_axis", "DXflash_mivec_target_rpm_axis", flash_mivec_target_stock,
               flash_mivec_load_axis_stock);
