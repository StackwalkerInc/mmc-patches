/* SPDX-License-Identifier: GPL-3.0-or-later */
	.text
memfun_erase_page:
	; The bootloader's erase-trigger always sweeps the full hardcoded
	; [0x8000,0x60000) userspace range, regardless of what RequestDownload
	; declared. Only redirect calls that fall in the declared carrier
	; window [0x10000,0x30000); every other call must no-op instead of
	; writing to a computed address that could land past physical flash.
	seth r3,#0x1
	cmpu r0,r3
	bc skip_page		; if (r0 < 0x10000) skip

	seth r3,#0x3
	cmpu r0,r3
	bnc skip_page		; if (r0 >= 0x30000) skip

	seth r2,#0x5
	add r0,r2		; r0 += 0x50000 (redirect into 0x60000-0x80000)

	ldi r4,#0x2020
	sth r4,@r0

	ld24 r4,#0xd0d0
	sth r4,@r0

	ldi r4,#50
wait1us:
	addi r4,#-1
	bnez r4,wait1us

	seth r8,#0x016e
	or3 r8,r8,#0x3600	; 24,000,000 - should be enough
waitbusy:
	ld24 r1,#0x805654	; bootloader_heartbeat
	jl r1
	ld24 r1,#0x8007e1
	ldub r1,@r1
	and3 r1,r1,#0x1
	bnez r1,notbusy		; FBUSY
	addi r8,#-1
	bnez r8,waitbusy

	bra notbusy

skip_page:
	ldi r8,#1		; report success without touching flash
	bra notbusy

filler:
	ld24 r2,#0xffffff
	ld24 r2,#0xffffff
	ld24 r2,#0xffffff
	ld24 r2,#0xffffff
	ld24 r2,#0xffffff
	ld24 r2,#0xffffff
	ld24 r2,#0xffffff
	ld24 r2,#0x8888c9
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

notbusy:
	ldi r0,#1
	bnez r8,exit
	ldi r0,#0
exit:
	.end
