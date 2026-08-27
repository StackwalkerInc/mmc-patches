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
  the stock mode index (`mode_idx`), which the ROM's own 8-way multimap
  machinery already consumes — no changes to the stock multimap lookup
  logic were needed.
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
deliberately left for bench confirmation before broader use:

- **Mod-owned RAM block `0x8047E6`-`0x804800`** (mode selector state: alt
  mode index, mode-change CEL pattern/timer, position-lights edge state).
  Verified clean of any *statically discoverable* access — fp-relative
  loads/stores, `ld24`/`seth`+`add3` immediate construction, word-aligned
  pointer scans of the stock ROM, `add3`-family base-register
  construction, and begin/end sweep-pair (memzero) detection all show zero
  hits in this range — but a computed access (register-plus-large-
  displacement addressing that isn't a literal `@(disp,fp)` form) could
  not be exhaustively excluded by these methods. Recommend a bench check
  that this RAM is undisturbed by anything else in the ROM before relying
  on it long-term.
- **Tachometer RPM scaling** (`real_rpm = hires_ticks * 125 / 256`, the
  integer inverse of the stock `RPM_TO_HIRESTICKS` `*2.048` conversion).
  Resolved to medium confidence from static analysis (frame-layout
  documentation and a physical-constant cross-check), not bench-verified.
  If the scale is off, the consequence is cosmetic — the parked tach
  needle sits a few percent away from the intended 2500/5000 RPM — not a
  drivability or safety issue.
- **`GUARD_RAISE_P0606` ships disabled** (commented out in the Makefile's
  `DEFINES`). It would make the integrity guard call the stock `set_dtc`
  function (confirmed `set_dtc(0, 3)` at the ROM's own CRC-failure call
  site) to raise a real DTC on a failed top-region check. Enable it only
  after bench-confirming that calling `set_dtc(0, 3)` is safe that early
  in ECU init — it has not been exercised at that point in the boot
  sequence by anything in this build.
- **The flash CRC is never recomputed by this build.** There is no CRC
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
