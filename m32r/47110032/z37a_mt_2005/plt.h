// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef MMC_PLT_H
#define MMC_PLT_H

extern void *procedura_linkage_table[16];

#define PLT_INDEX_MAIN_LOOP 0
#define PLT_INDEX_4dfe8 1
#define PLT_INDEX_EEPROM_DEFAULTS 2

typedef void (*main_loop_type)();
typedef void (*eeprom_defaults_type)(uint8_t);

#define main_loop (main_loop_type)(procedure_linkage_table[PLT_INDEX_MAIN_LOOP])
#define eeprom_defaults (eeprom_defaults_type)(procedure_linkage_table[PLT_INDEX_EEPROM_DEFAULTS])

#endif /*MMC_PLT_H*/
