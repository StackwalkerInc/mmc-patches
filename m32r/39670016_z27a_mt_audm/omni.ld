/* SPDX-License-Identifier: GPL-3.0-or-later */
INCLUDE ../m32170.ld
INCLUDE ../math.ld
INCLUDE description.ld

SECTIONS {
	"ReplaceROMID" 0x222 : { LONG(0x3967a016) }
	INCLUDE ../load400.ld

	/* OBD mode 0x23 injected core (ROM-agnostic obd_mode23.c). Placed in the
	   erased flash tail (0x6a96c..0xc0000 is all 0xff). */
	"OBD Mode23 Core" 0x6b000 : {
		../../src/obd_mode23.o(.text)
		../../src/obd_mode23.o(.rodata*)
	}

	/* K-Line: replace `lduh r0,sio0_tx_count` with a call to the self-contained
	   rest-handler (returns sio0_tx_count, dispatches service 0x23). */
	"OBD Mode23: K-Line dispatch [m32r-bl]" obd_rest_handler_injection_location : {
		LONG(obd_mode23_rest_handler)
	}

	/* CAN slot 12 (physical 0x7E0): replace `bl canrx12_15_process` with the
	   trampoline. Original is a long bl (fe000094). */
	"OBD Mode23: CAN trampoline slot12 [m32r-bl]" canrx12_15_call_location_slot12 : {
		LONG(canrx12_15_process_trampoline)
	}

	/* CAN slot 15 (functional 0x7DF): same trampoline. Original is a short bl +
	   filler (7e5ef000); the long bl replaces the full word, return addr 0x49ea0
	   preserved. */
	"OBD Mode23: CAN trampoline slot15 [m32r-bl]" canrx12_15_call_location_slot15 : {
		LONG(canrx12_15_process_trampoline)
	}

	"data_desc" 0x60000 : {
		*(data_desc)
	}
}
