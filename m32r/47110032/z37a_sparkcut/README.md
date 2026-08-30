<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
# Colt CZT Z37A 1.5T 5MT (2005) — `47110032` "sparkcut" target

Modern-suite proof-of-concept build for the Z37A. In addition to the
patches shared with `z37a_mt_2005` (rolling spark cut, knock CEL), this
target uses the top 128KB of flash (`0x60000`-`0x80000`, previously unused
by the stock ROM) to carry a second, independently tunable map set and the
wider load axes it needs. Design spec (not part of this repository):
`docs/superpowers/specs/2026-08-26-z37a-top128k-extended-maps-design.md`.

## Features

- **Extended load maps + alternate map set.** Replaces the stock fuel,
  spark and MIVEC target load axes with wider ones and adds a second
  complete map set, both stored in the top 128KB. Map bodies for both the
  main and alt sets are seeded from the stock ROM at build time, so a
  freshly built image behaves exactly like stock until the alt set is
  tuned to different values.
- **Multi-map mode selector.** Toggles between the main and alt map sets
  by depressing the clutch and switching the position lights on (rising
  edge). Mode resets to main on every ignition cycle; a TPS blip above
  threshold within the first ~40 update cycles also selects alt. Drives
  the stock mode index (`mode_idx` at `0x804DA0`), which the ROM's own
  8-way multimap machinery already consumes — no changes to the stock
  multimap lookup logic were needed. The write is made from a wrapper
  around the *call* to `update_multimode_selection` (the 16-bit `bl` at
  `0x109e0`, inside `base_engine_state_update`), **after** that stock
  function's own unconditional `mode_idx = 0` store at `0x10ae8` — not
  from inside it, where the stock recompute would destroy it on every
  main-loop iteration. See `mode_bridge.c` for the full derivation.
- **ETACS position-lights handler.** Decodes the position-lights bit off
  the ETACS CAN frame (`sid 0x423`, `data[0] & 0x04`) through the
  confirmed Z37A CAN RX dispatch-table hook, feeding the mode selector.
- **Tachometer mode indication.** Parks the tachometer at a configurable
  per-mode RPM (2500 main / 5000 alt) for a short window after each mode
  change, by overwriting the engine-to-dash CAN frame's tach field
  (`engine_rpm_direct_bound`, frame `sid 0x308`, `data[1..2]` big-endian)
  in `can_tx2_id3_dash_update`. Both stock calls the hijacked call site
  used to make (`can0_update_bus_state`, `can0_update_tx_data`) are still
  made — only the tach value is overridden, and only for the length of the
  indication window.
- **Top-region integrity guard.** A `bra` at the `0x8080` PLT slot (which
  the bootloader's `choose_main` calls into) now goes through
  `top_region_guard` instead of jumping straight to `main_loop`. The guard
  checks a magic word (`0x5a37a001`) at `0x60000` before letting
  `main_loop()` run; on mismatch it calls the bootloader's own
  `integrity_fault_reinit_mcu` instead.

## Flashing this variant requires FastECU, not EcuFlash

The top 128KB carries live map data and the integrity-guard magic word.
EcuFlash's `mitsubootloader` flash method only writes `0x8000`-`0x60000` —
it never touches the top 128KB at all. **Flashing this variant with
EcuFlash will produce an ECU that boots straight into the bootloader and
will not run engine control.** This is the top-region integrity guard
working exactly as designed — it refuses to run on a top region that was
never written (and would otherwise contain erased `0xFF` map data) — not a
brick. Recovery is a full reflash (including the top 128KB) with a tool
that writes the whole image, e.g. FastECU.

## Bench qualification

This suite has been verified statically (disassembly, byte-level diffing,
and build-time checks) but not yet on a running vehicle. The following are
deliberately left for bench confirmation before broader use, in rough
priority order:

1. **Confirm the alt map set actually engages.** Read `mode_idx` at
   `0x804DA0` over OBD mode `0x23`, *after* at least one full main-loop
   iteration has completed, both before and after the clutch + position-
   lights gesture, with the alt set built to a deliberately different
   value from main so the difference is observable. This is the single
   most important check on the whole target: the map-switch mechanism was
   inert in an earlier revision of this branch (the stock
   `update_multimode_selection` recompute overwrote `mode_idx` on every
   iteration) and the defect was invisible precisely because a
   stock-seeded alt set is byte-identical to main. Static analysis says
   it is fixed; only this check proves it.
2. **Never flash a tuned alt set until (1) passes.** Until the switch is
   confirmed on a bench, a tuned alt set combined with the mode
   indication below means the ECU can *tell the driver* one profile is
   active while running the other — a tuned-alt-plus-lying-tach
   combination is dangerous in a way a stock-seeded one is not.
3. **Confirm the top 128KB was actually written** — read back `0x60000`
   and check it reads `5a37a001`, **before the first key-on**. On a tool
   that silently skips the top region the guard will hand control to the
   bootloader instead, which looks like a no-start.
4. **Mod-owned RAM block `0x8047E6`-`0x804800`** (mode selector state: alt
   mode index, mode-change CEL pattern/timer, position-lights edge state).
   Verified clean of any *statically discoverable* access — fp-relative
   loads/stores, `ld24`/`seth`+`add3` immediate construction, word-aligned
   pointer scans of the stock ROM, `add3`-family base-register
   construction, and begin/end sweep-pair (memzero) detection all show zero
   hits in this range — but a computed access (register-plus-large-
   displacement addressing that isn't a literal `@(disp,fp)` form) could
   not be exhaustively excluded by these methods.
   **This class of defect recurred three separate times while searching
   for this block**: the original `0x8054C8` choice sat on a live OBD DTC
   descriptor block reached through 32-bit absolute pointers held in flash
   data; a `0x8055C0` 23-entry DTC bitmask array and a `0x8044BE`
   10-entry struct array were each addressed only through a runtime
   `add3 rN,fp,#imm` base plus a loop increment. All three are invisible
   to displacement, `ld24` and pointer scanning. Two of the three are
   fault/diagnostic state, i.e. structures a cold ECU never populates —
   so this block must be validated **with the engine running at operating
   temperature, with O2 feedback closed-loop and fuel trims active**. A
   cold bench ECU does not exercise the mechanism that bit twice before,
   and a clean cold-bench result is not evidence.
5. **Tachometer RPM scaling** (`real_rpm = hires_ticks * 125 / 256`, the
   integer inverse of the stock `RPM_TO_HIRESTICKS` `*2.048` conversion).
   Resolved to medium confidence from static analysis (frame-layout
   documentation and a physical-constant cross-check), not bench-verified.
   If the scale is off, the consequence is cosmetic — the parked tach
   needle sits a few percent away from the intended 2500/5000 RPM — not a
   drivability or safety issue.
6. **`GUARD_RAISE_P0606` ships disabled** (commented out in the Makefile's
   `DEFINES`). It would make the integrity guard call the stock `set_dtc`
   function (confirmed `set_dtc(0, 3)` at the ROM's own CRC-failure call
   site) to raise a real DTC on a failed top-region check. Enable it only
   after bench-confirming that calling `set_dtc(0, 3)` is safe that early
   in ECU init — it has not been exercised at that point in the boot
   sequence by anything in this build.
7. **The flash CRC is never recomputed by this build.** There is no CRC
   step anywhere in `mmc-patches` (a CRC fixup tool, `crc_checker`, exists
   only in the separate `mmc-research` repo and is not run here). The
   patched image's flash CRC is therefore stale after any patch is
   applied — not specific to this target's top-128KB work. The
   likely-but-unconfirmed consequence is a stored DTC and a lit MIL rather
   than a failure to boot: the bootloader-entry path exercised by this
   suite's own guard is the separate `is_code_integrity_ok()` magic-word
   check, not the CRC. This is a pre-existing gap across the whole repo,
   not something introduced by this plan, and is out of scope to fix here —
   flagging it for bench confirmation of the stale-CRC behaviour before
   relying on MIL/DTC state being clean after a flash.
8. **Deliberately mis-flash `0x8000`-`0x60000` only**, confirm the ECU
   enters the bootloader rather than running engine control on erased map
   data, and confirm a full FastECU reflash (including the top 128KB)
   recovers it. This is the top-region integrity guard's entire purpose
   and the branch's only irreversible-looking failure mode, and it has
   never been exercised — neither the guard's bootloader hand-off nor the
   recovery path has been run once on real hardware. Do this before any
   flash that a normal user could repeat, and do it on an ECU you can
   recover with `boot-talk` if the hand-off does not behave as analysed.
