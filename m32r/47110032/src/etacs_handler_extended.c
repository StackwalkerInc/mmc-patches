// SPDX-License-Identifier: GPL-3.0-or-later
#include "stdint.h"

extern unsigned can_rx_etacs_handler1(uint8_t *data);

/*used for position lights*/
uint8_t can_rx1_data0_u8;

unsigned can_rx_etacs_extended_handler(uint8_t *data)
{
	can_rx1_data0_u8 = data[0];
	return can_rx_etacs_handler1(data);
}
