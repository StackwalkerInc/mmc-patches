// SPDX-License-Identifier: GPL-3.0-or-later
/*
 * Bridge between mode_selector_v2's selection and the stock 8-way multimap
 * machinery.
 *
 * The stock code already computes mode_idx for us.  update_multimode_selection
 * (0x10a9c) does:
 *
 *     bl   adc_convert_mode_input        ; 0x10aa0
 *     idx  = (adc_byte_mode >> 5) & 7    ; 0x10aa4..0x10aac
 *     if (*0x50012)                      ; "use mode index table" flag
 *             v = ((uint16_t *)0x5002a)[idx];
 *     else
 *             v = *(uint16_t *)0x50010;
 *     mode_idx = (v > 7) ? 0 : v;        ; 0x10ae8
 *
 * so supplying adc_byte_mode is enough: flip the flag, make the table the
 * identity, and the stock algorithm sets mode_idx itself.  Nothing has to
 * write mode_idx, so nothing can be clobbered by the stock store at 0x10ae8.
 *
 * adc_convert_mode_input (0xb314) is a three-instruction stub on this ROM --
 * "adc_byte_mode = 0; return" -- so hijacking its call site loses nothing.
 * We cannot patch the stub itself: it has no `push lr`, so a bl planted at
 * 0xb314 would overwrite lr and its own `jmp lr` would loop back into it.
 *
 * 0x49f38 is a second call to the same stub, followed by an inlined copy of
 * the same sequence.  It is the EEPROM reinitialisation path after an
 * integrity failure, gated on integrity_fault (fp-122), and never runs in the
 * normal main loop, so it is deliberately left alone.
 */
#include <stdint.h>

extern uint16_t new_mode_idx;

/* Stock ADC mode input, consumed by 0x10aa4 as (adc_byte_mode >> 5) & 7. */
extern uint16_t adc_byte_mode;

/* mode_selector_v2: stock stub, then update_mode_selector(), then new_mode_idx. */
extern void new_adc_convert_mode_input(void);

void z37a_convert_mode_input(void)
{
	new_adc_convert_mode_input();
	adc_byte_mode = new_mode_idx << 5;
}
