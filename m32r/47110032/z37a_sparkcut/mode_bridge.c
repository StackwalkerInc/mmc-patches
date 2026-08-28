// SPDX-License-Identifier: GPL-3.0-or-later
/* Drives the stock mode_idx (RAM 0x804da0, read by multimap8u16 at 0x4e7ec
   as ptr[mode_idx & 7]) from mode_selector_v2's new_mode_idx.
 *
 * WHERE THE WRITE HAS TO GO (this is the whole point of this file).
 *
 * The obvious place -- inside the 0x10aa0 hijack, i.e. from within
 * update_multimode_selection() -- does not work. update_multimode_selection
 * (0x10a9c) RECOMPUTES mode_idx from its own stock inputs and stores the
 * result unconditionally eighteen instructions after 0x10aa0:
 *
 *   10aa0: bl 0xb314            <- the 0x10aa0 hijack lands here
 *   10ab4: ld24 r4,0x50012 ; lduh r0,@r4        -> 0x0000 in this ROM
 *   10abc: beqz r0,0x10ad4                       -> taken
 *   10ad4: ld24 r4,0x50010 ; lduh r0,@r4        -> 0x0000
 *   10ae0: ldi r2,#7 ; cmpu r2,r1                -> C = (7 <u 0) = 0
 *   10ae4: bnc 0x10ae8 -> ldi r0,#0              -> taken, r0 = 0
 *   10ae8: sth r0,@(-12896,fp)                   -> mode_idx = 0
 *
 * Straight-line: the single if/else at 0x10abc/0x10ad0 reconverges at
 * 0x10adc and there is no early return, so anything written to mode_idx
 * from inside that call is destroyed before it returns, on every main-loop
 * iteration.  A driver would get the full "alt selected" confirmation (CEL
 * pattern + parked tach) while all 23 repointed lookups still resolved
 * slot 0 -- i.e. the tach would lie about which tune is running.
 *
 * So the write is made from a wrapper around the CALL to
 * update_multimode_selection(), after the stock recompute has already
 * stored its own value:
 *
 *   109dc: push lr                    <- base_engine_state_update
 *   109e0: bl 0x10a9c || nop          <- HIJACKED to this wrapper
 *
 * That call site is the main loop's only path into
 * update_multimode_selection (0x4e130 -> 0x4e178 -> 0x109dc -> 0x109e0);
 * the other two callers, 0x1008c and 0x10414, are init-only (both reached
 * from main_loop's pre-loop prologue at 0x4e13c, before `bra 0x4e148`).
 * The wrapper runs before base_engine_state_update's own MIVEC lookup at
 * 0x10a40 and before every later main-loop call, so mode_idx is correct
 * for every repointed table read in the same iteration.
 *
 * Safe to drive globally: every stock array indexed by mode_idx holds the
 * same value in slots 0 and 1 (the only values the selector emits) --
 * 0x5006a, 0x5007a, 0x5008a, 0x5009a, 0x500aa, 0x500ba, 0x50014, 0x5005a,
 * 0x5002a as u16[8], 0x5003a as u32[8] -- so nothing but the tables
 * repointed in omni.ld is affected.  (0x49f80 is a second stock store to
 * mode_idx, but it lives in the 0x49f28 bootloader-side routine reached
 * only by `bra` from the 0x8088 PLT slot and gated on integrity_fault
 * (fp-122); it never runs in the normal main loop.)
 *
 * The selector itself still runs from the 0x10aa0 hijack, which now points
 * straight at mode_selector_v2's new_adc_convert_mode_input(): the stock
 * ADC mode conversion must happen exactly once and at its stock point in
 * the sequence, because the very next instruction (0x10aa4) consumes what
 * it wrote.  Folding it into this wrapper instead would either call it
 * twice or move it after code that reads its result.
 */
#include <stdint.h>

extern uint16_t new_mode_idx;
extern uint16_t mode_idx;

/* Stock update_multimode_selection(); bound to 0x10a9c in description.ld. */
extern void update_multimode_selection(void);

void update_multimode_selection_z37a(void)
{
	update_multimode_selection();
	mode_idx = new_mode_idx;
}
