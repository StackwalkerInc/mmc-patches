// SPDX-License-Identifier: GPL-3.0-or-later
/* Fails safe when the top 128KB was never written. Reached via the 0x8080 PLT
   slot (stock: bra main_loop), so it runs before any user code and lives
   entirely above 0x8000 -- the bootloader is called, never patched.
   On mismatch it hands over to the bootloader's own integrity_fault_reinit_mcu
   (0x4c98), which sets integrity_fault = 1 and enters bootloader_main(),
   mirroring the ROM's response to is_code_integrity_ok() failing. */
#include <stdint.h>

#define TOP_REGION_MAGIC 0x5a37a001u

extern const uint32_t flash_top_region_magic;

extern void main_loop(void);
extern void integrity_fault_reinit_mcu(void);
#ifdef GUARD_RAISE_P0606
extern void set_dtc(unsigned p0, unsigned p1);
#endif

void top_region_guard(void)
{
	if (flash_top_region_magic != TOP_REGION_MAGIC) {
#ifdef GUARD_RAISE_P0606
		set_dtc(0, 3);
#endif
		integrity_fault_reinit_mcu();
	}
	main_loop();
}
