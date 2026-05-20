// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef OBD_DATA_H
#define OBD_DATA_H

#include <stdint.h>

#define VIN_SIZE 4

extern const uint16_t flash_vin_signature[VIN_SIZE];
extern const unsigned flash_key_moduli[VIN_SIZE];

extern uint8_t vin[VIN_SIZE];
extern uint8_t shadow_vin[VIN_SIZE];
extern uint16_t vin_volatility;

#endif /*OBD_DATA_H*/
