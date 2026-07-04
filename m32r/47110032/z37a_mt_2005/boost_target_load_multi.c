// SPDX-License-Identifier: GPL-3.0-or-later
#include "fmath.h"
#include "memaccess.h"
#include "memory_map.h"

extern const void *flash_boost_control_3d_rpm_axis;
extern const void *flash_boost_control_3d_tps_axis;
extern const void *flash_boost_control_target_load_high_gear_3dmap8_stock;
extern const void *flash_boost_control_target_load_low_gear_3dmap8_stock;

#define BOOST_CONTROL_HIGH_GEAR 0x0200

DECLARE_3DMAP8(flash_boost_control_target_load_3dmap8_mod, 13,
               7) = {TEMP_3DMAP_SRC, .xsize = 13,
                     .data = {
                         88,  64,  48,  28,  19,  11,  7,   3,   0,   0,   0,   0,   0,   107, 128, 143, 136, 131, 114,
                         100, 87,  75,  66,  59,  52,  46,  109, 136, 192, 200, 197, 179, 160, 158, 149, 144, 133, 123,
                         101, 109, 136, 200, 214, 216, 203, 197, 197, 197, 190, 178, 165, 141, 109, 136, 207, 223, 227,
                         227, 227, 230, 230, 237, 224, 205, 184, 109, 136, 207, 229, 238, 237, 233, 236, 237, 244, 240,
                         213, 197, 109, 136, 207, 229, 238, 237, 233, 236, 237, 244, 240, 213, 197,
                     }};

const void *const flash_boost_control_target_load_high_gear_3dmultimap8[8] = {
    &flash_boost_control_target_load_high_gear_3dmap8_stock,
    &flash_boost_control_target_load_high_gear_3dmap8_stock,
    &flash_boost_control_target_load_high_gear_3dmap8_stock,
    &flash_boost_control_target_load_high_gear_3dmap8_stock,
    &flash_boost_control_target_load_3dmap8_mod,
    &flash_boost_control_target_load_3dmap8_mod,
    &flash_boost_control_target_load_3dmap8_mod,
    &flash_boost_control_target_load_3dmap8_mod,
};

const void *const flash_boost_control_target_load_low_gear_3dmultimap8[8] = {
    &flash_boost_control_target_load_low_gear_3dmap8_stock,
    &flash_boost_control_target_load_low_gear_3dmap8_stock,
    &flash_boost_control_target_load_low_gear_3dmap8_stock,
    &flash_boost_control_target_load_low_gear_3dmap8_stock,
    &flash_boost_control_target_load_3dmap8_mod,
    &flash_boost_control_target_load_3dmap8_mod,
    &flash_boost_control_target_load_3dmap8_mod,
    &flash_boost_control_target_load_3dmap8_mod,
};

ROM_SECTION("boost_target_load") void update_boost_target_load()
{
	calc_axis(&flash_boost_control_3d_rpm_axis);
	calc_axis(&flash_boost_control_3d_tps_axis);

	writeu16(multimap8u16(IS_BIT_SET16(boost_control_flags, BOOST_CONTROL_HIGH_GEAR)
	                          ? &flash_boost_control_target_load_high_gear_3dmultimap8
	                          : &flash_boost_control_target_load_low_gear_3dmultimap8),
	         boost_target_load);
}
