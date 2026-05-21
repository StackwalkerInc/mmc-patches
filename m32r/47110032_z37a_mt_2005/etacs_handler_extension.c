// SPDX-License-Identifier: GPL-3.0-or-later
#include "stdint.h"
#include "memaccess.h"
#include "memory_map.h"

extern const uint16_t flash52530_u16;
extern const uint16_t flash526d6_u16;

unsigned can_rx_etacs_extended_handler(uint8_t *data)
{
	pushi();
	writeu8(data[0], can_rx1_data0_u8);
	writeu16(data[3], can_rx1_data3_u16);
	writeu16(flash52530_u16, decays_x1_canrx1_etacts_short);
	writeu16(flash526d6_u16 * 40, decays_x1_canrx1_etacts_long);
	popi();
	return 0;
}
