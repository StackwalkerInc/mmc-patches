// SPDX-License-Identifier: GPL-3.0-or-later
#include "memaccess.h"
#include "memory_map.h"
#include "fmath.h"

#if 1
const uint16_t flash_apps_to_ttp_correction_high_gear_ratio_multiu16a[8] = {0x7b8,  0xffff, 0xffff, 0xffff,
                                                                            0xffff, 0xffff, 0xffff, 0xffff};
#else
const uint16_t flash_apps_to_ttp_correction_high_gear_ratio_multiu16a[8] = {
    0x7b8, 0x7b8, 0x7b8, 0x7b8,

    0x7b8, 0x7b8, 0x7b8, 0x7b8,
};
#endif

void update_low_gear_flags_and_apps_limit()
{
	BIT_CONDITION16(low_gear_flags, 0x01,
	                readu16(gear_ratio) >= (multiu16(flash_apps_to_ttp_correction_high_gear_ratio_multiu16a) + 1));
}
