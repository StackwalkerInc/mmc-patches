/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE ../m32170.ld
INCLUDE ../math.ld
INCLUDE description.ld

SECTIONS {
	"ReplaceROMID" 0x222 : { LONG(0x3967a016) }
	INCLUDE ../load400.ld

	/* OBD service core — dispatch_kline.o and dispatch_can.o are the only
	   compilation units; service fragment files are #included into them. */
	"OBD Services" 0x6b000 : {
		../../src/obd/dispatch_kline.o(.text)
		../../src/obd/dispatch_kline.o(.rodata*)
		../../src/obd/dispatch_can.o(.text)
		../../src/obd/dispatch_can.o(.rodata*)
	}

	/* K-Line: replace `lduh r0,sio0_tx_count` with a call to the generic
	   K-Line rest-handler (returns sio0_tx_count, dispatches all OBD services). */
	"OBD K-Line dispatch [m32r-bl]" obd_rest_handler_injection_location : {
		LONG(obd_kline_rest_handler)
	}

	/* CAN slot 12 (physical 0x7E0): replace `bl canrx12_15_process` with the
	   trampoline. Original is a long bl (fe000094). */
	"OBD CAN trampoline slot12 [m32r-bl]" canrx12_15_call_location_slot12 : {
		LONG(canrx12_15_process_trampoline)
	}

	/* CAN slot 15 (functional 0x7DF): same trampoline. Original is a short bl +
	   filler (7e5ef000); 0x49e9e (0xf000) is the inert low slot of the short-bl
	   word, not an independent instruction, so the 4-byte long bl replaces the
	   full word and return addr 0x49ea0 is preserved. */
	"OBD CAN trampoline slot15 [m32r-bl]" canrx12_15_call_location_slot15 : {
		LONG(canrx12_15_process_trampoline)
	}

	"data_desc" 0x60000 : {
		*(data_desc)
	}
}
