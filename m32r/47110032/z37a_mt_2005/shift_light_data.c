// SPDX-License-Identifier: GPL-3.0-or-later
#include "shift_light.h"

#define SL_X_TO_RPM(x) ((x) * 256 / 1000)
const uint16_t flash_shift_light_engine_rpm[6] = {
    SL_X_TO_RPM(5000), SL_X_TO_RPM(5000), SL_X_TO_RPM(5800),

    SL_X_TO_RPM(5800), SL_X_TO_RPM(6000), SL_X_TO_RPM(6500),
};
