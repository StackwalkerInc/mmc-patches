// SPDX-License-Identifier: GPL-3.0-or-later
/* This patch set doesn't ship mode_selector_v2, but the shared sources
   (knock_mil_simple.c, colt_mt_cvt_dash_control.c) still reference its
   `alt_mode_change_cel` function inside branches guarded by a
   zero-valued alt-mode timer (provided as a stock RAM address that
   nothing writes to). Stub the function so the link resolves; the call
   never executes at runtime. */
#include <stdint.h>

uint16_t alt_mode_change_cel(void)
{
	return 0;
}
