// SPDX-License-Identifier: GPL-3.0-or-later
#include "stdint.h"

#include "mode_selector.h"

extern unsigned can_rx_etacs_handler1(uint8_t *data);

/* Mode selector input, bound absolutely in description.ld (0x8047EE); this
   is a reference to the mod-owned RAM, not a definition. */
extern uint8_t position_lights;

/*used for position lights*/
uint8_t can_rx1_data0_u8;

unsigned can_rx_etacs_extended_handler(uint8_t *data)
{
	can_rx1_data0_u8 = data[0];
	position_lights = (data[0] & MODE_SELECTOR_POSITION_LIGHTS) ? 1 : 0;
	return can_rx_etacs_handler1(data);
}
