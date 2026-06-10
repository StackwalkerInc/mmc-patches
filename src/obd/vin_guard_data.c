// SPDX-License-Identifier: GPL-3.0-or-later
// Included by dispatch_kline.c when FEATURE_OBD_VIN_GUARD is defined.
#include <fmath.h>
#include <maps_decl.h>

#define VIN_SIZE 4

/* RAM symbols — bound per-ROM via description.ld PROVIDE. */
extern uint8_t vin[VIN_SIZE];
extern uint8_t shadow_vin[VIN_SIZE];
extern uint16_t vin_volatility;

DECLARE_ARRAY_DESC(flash_vin_signature, "Guards", "Signature", "Hex16",
                   "<table name=\"X\" type=\"Static X Axis\" elements=\"4\">"
                   "<data>0</data>"
                   "<data>1</data>"
                   "<data>2</data>"
                   "<data>3</data>"
                   "</table>");

const uint16_t flash_vin_signature[VIN_SIZE] = {

};

const unsigned flash_key_moduli[VIN_SIZE] = {
    SECRET_KEY0,
    SECRET_KEY1,
    SECRET_KEY2,
    SECRET_KEY3,
};
