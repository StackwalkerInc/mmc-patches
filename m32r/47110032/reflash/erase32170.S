/* SPDX-License-Identifier: GPL-3.0-or-later */
	.text
memfun_erase_page:
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

filler:
	ld24 r2,#0xffffff
	ld24 r2,#0xffffff
	ld24 r2,#0xffffff
	ld24 r2,#0xffffff
	ld24 r2,#0xffffef
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
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
