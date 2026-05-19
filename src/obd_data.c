#include "obd_data.h"
#include <fmath.h>
#include <maps_decl.h>

DECLARE_ARRAY_DESC(flash_vin_signature,
	"Guards",
	"Signature",
	"Hex16",
	"<table name=\"X\" type=\"Static X Axis\" elements=\"4\">"
	"<data>0</data>"
	"<data>1</data>"
	"<data>2</data>"
	"<data>3</data>"
	"</table>");

const uint16_t flash_vin_signature[VIN_SIZE] = {

};

#if 0
const unsigned flash_key_moduli[VIN_SIZE] = {
	55417,
	65411,
	59909,
	52303,
};

#else
const unsigned flash_key_moduli[VIN_SIZE] = {
	SECRET_KEY0,
	SECRET_KEY1,
	SECRET_KEY2,
	SECRET_KEY3,
};
#endif
