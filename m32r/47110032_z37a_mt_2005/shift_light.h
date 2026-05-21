// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef SHIFT_LIGHT_H
#define SHIFT_LIGHT_H

#include <stdint.h>

extern uint8_t shift_light_state;

extern const uint16_t flash_shift_light_engine_rpm[6];

extern void update_shift_light();

#define SHIFT_LIGHT_STATE_NONE 0
#define SHIFT_LIGHT_STATE_UP 1
#define SHIFT_LIGHT_STATE_DOWN 2
#endif /*SHIFT_LIGHT_H*/
