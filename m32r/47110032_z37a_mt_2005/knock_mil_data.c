// SPDX-License-Identifier: GPL-3.0-or-later
#include <stdint.h>

#include "memaccess.h"

ROM_SECTION("knock_mil_data_section")
const uint16_t flash_init_knock_mil_flash_timer[4] = {
    0,
    40,
    20,
    10,
};

ROM_SECTION("knock_mil_data_section") const uint16_t flash_init_knock_mil_flash_decay = 80;

ROM_SECTION("knock_mil_data_section") const uint8_t flash_knock_mil_thresholds[6] = {3, 5, 6, 8, 9, 11};

ROM_SECTION("knock_mil_data_section") const uint16_t flash_knock_mil_load_min = 320; // 100% load
ROM_SECTION("knock_mil_data_section") const uint16_t flash_knock_mil_tps_min = 0x80; // 50% tps
