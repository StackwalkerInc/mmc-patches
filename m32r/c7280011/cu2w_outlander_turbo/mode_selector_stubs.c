// SPDX-License-Identifier: GPL-3.0-or-later
/* Same stub as the 3352a3a3 port: mmc-research's omni.ld for this ROM
   doesn't include mode_selector_v2, but the shared knock_mil_simple.c
   references its `alt_mode_change_cel` function inside a branch guarded
   by a zero-valued alt-mode timer. */
#include <stdint.h>

uint16_t alt_mode_change_cel(void)
{
	return 0;
}
