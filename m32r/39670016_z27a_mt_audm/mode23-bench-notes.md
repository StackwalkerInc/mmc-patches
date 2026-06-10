# OBD Mode 0x23 — Bench Qualification Notes (39670016)

Mode 0x23 (ReadMemoryByAddress) is read-only and qualified on a bench ECU, not
in CI. Static analysis fixed the addresses below; confirm these live:

## K-Line (MUT)
- Injection at `0x60248` replaces `lduh r0,@(sio0_tx_count,fp)` with
  `bl obd_mode23_rest_handler`. The handler dispatches service 0x23 and returns
  sio0_tx_count, so the following `beq r0,...` test still behaves.
- Request: `23 <addr_hi> <addr_mid> <addr_lo> <count>`; expect response
  `63 <count bytes>`. Confirm the stock dispatcher frames the `0x63` mode byte
  (request 0x23 + 0x40) and that data lands at sio0_tx_buffer[4..] with
  sio0_tx_count = 5 + count.
- count is clamped to 10 (sio0_tx_buffer[15], data [4..13], checksum at [4+count]).

## CAN (ISO 15765-4, single-frame)
- Trampoline at `0x49dc4` replaces `bl canrx12_15_process` and FORWARDS r0
  (the call site sets `r0=2` before the call). Confirm canrx12_15_process still
  receives its argument and the slot-12/15 paths behave for non-0x23 services.
- For service 0x23: confirm the trampoline's `r5=1` positive / `r5=3` negative
  return drives the caller's slot-5 (0x7E8) send, and that the response frame
  layout (cantx5_data0 = PCI, +1 = 0x63, +2.. = data) is correct on the wire.
- count capped at 6 (single frame); larger → NRC 0x14.

## Addresses (39670016)
- canrx12_15_process = 0x4a014
- sio0_rx_buffer = 0x8053d8, sio0_tx_buffer = 0x8053ee, sio0_tx_count = 0x805430
- canrx12_data = 0x805c0c, cantx5_data0 = 0x805c14
- mode23 core = 0x6b000

## CAN — both diagnostic channels (dual call-site fix, 2026-06-09)
- The trampoline is now injected at BOTH callers of canrx12_15_process:
  - 0x49dc4 (long bl, `ldi r0,#2`) -> slot 12 / canrx12_data (physical 0x7E0)
  - 0x49e9c (short bl `7e5ef000`, `ldi r0,#1`) -> slot 15 / canrx15_data (functional 0x7DF)
- The slot-15 injection replaces the full 4-byte word with a long bl; return
  address 0x49ea0 is preserved.
- **MUST VERIFY BEFORE FLASHING (static — no bench needed):** the low half-word
  at 0x49e9e (0xf000) is inert slot filler, NOT a live parallel op, so the long
  bl can consume it. Static evidence: 0xf000 appears uniformly as the low-slot
  filler paired with every 16-bit high-slot instruction across this region
  (0x49e92, 0x49e9a, 0x49e9e, 0x49ea6, 0x49eaa, 0x49eae all = 0xf000). The
  high-slot short bl `7e5e` targets (0x49e9c & ~3) + 0x5e*4 = 0x4a014
  (canrx12_15_process), confirming the decode. If a future port shows anything
  other than 0xf000 at the +2 half-word of the slot-15 bl site, do NOT inject —
  re-derive the site. (See description.ld: `word = 7e5ef000`.)
- Confirm on the bench that the slot-15 path returns correctly.
- Bench-qualify mode 0x23 over BOTH physical (0x7E0) and functional (0x7DF)
  addressing. Confirm the slot-15 caller performs the same r5->slot-5 (0x7E8)
  send as the slot-12 caller; if the functional path frames/suppresses responses
  differently, the intercept parses but the reply path may differ.
- canrx15_data = 0x805c04 (canrx12_data - 8) — verify on the bench ECU.

## Mode 0x3D (WriteMemoryByAddress) — added 2026-06-10

Request format (K-Line): `3D <addr_hi> <addr_mid> <addr_lo> <count> <data...>`
Response (positive): `7D` — no echoed data. Count capped at 7.
Verify on bench: stock framing sets sio0_tx_buffer[3] = 0x7D automatically (same
mechanism as 0x23 and 0xA1).

Request format (CAN, single-frame): `[PCI] 3D <addr_hi> <addr_mid> <addr_lo> <count> <b0> <b1>`
Response (positive): `[01] 7D`. Count capped at 2 (single-frame limit).
If count > 2: NRC 0x13 (incorrectMessageLengthOrInvalidFormat).

Bench checklist:
- Write 1 byte to a known RAM address; read back with mode 23 to confirm.
- Write 2 bytes (CAN max); read back with mode 23.
- Send count=3 over CAN; confirm NRC 0x13 response.
- Send a non-0x3D service after a 0x3D; confirm dispatch still forwards correctly.
