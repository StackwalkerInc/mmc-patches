/* SPDX-License-Identifier: GPL-3.0-or-later */
	.text
memfun_program_page:
	ldi r4,#0x4141
	sth r4,@r0

	add3 r5,r0,#256
program_loop:
	lduh r4,@r1
	sth r4,@r0
	addi r0,#2
	addi r1,#2
	bne r0,r5,program_loop

	ld24 r5,0xffffff
	ld24 r5,0xffffff
	ld24 r5,0xffffff
	ld24 r5,0xffffff
	ld24 r5,0xffffff

	ld24 r5,0xffffff
	ld24 r5,0xff0034
	ld24 r5,0xffffff

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
	nop
	nop

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

notbusy:
	ldi r0,#1
	bnez r8,exit
	ldi r0,#0
exit:
	.end
