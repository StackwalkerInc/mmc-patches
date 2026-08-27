// SPDX-License-Identifier: GPL-3.0-or-later
/* Drives the stock mode_idx (RAM 0x804da0, read by multimap8u16 at 0x4e7ec
   as ptr[mode_idx & 7]) from mode_selector_v2's new_mode_idx. Safe to drive
   globally: all sixteen stock multimap arrays hold the same pointer in all
   eight slots, so nothing but the tables repointed in omni.ld is affected. */
#include <stdint.h>

extern uint16_t new_mode_idx;
extern uint16_t mode_idx;

extern void new_adc_convert_mode_input(void);

void new_adc_convert_mode_input_z37a(void)
{
	new_adc_convert_mode_input();
	mode_idx = new_mode_idx;
}
