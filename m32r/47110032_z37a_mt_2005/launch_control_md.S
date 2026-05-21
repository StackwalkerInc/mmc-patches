/* SPDX-License-Identifier: GPL-3.0-or-later */
	.section md_replacetext, "a"
; can use r0, r1, r2, r3, r4. sp18 is ipw
replace_md_turntable:
	lduh r4,@(-12694,fp)
	addi r4,#1
	cmpui r4,#16
	bc no_wrap
	ldi r4,#0
no_wrap:
	sth r4,@(-12694,fp)

	ldub r1,@(-13018,fp)	; load launch_control_cut_count
	beqz r1, md_none
	addi r1, #-1
	slli r1, #4
	ld24 r2, flash_modulated_fuel_cut
	add r1, r2
	add r1, r4
	ldub r0,@r1
	bnez r0, md_none
	add3 r4,sp,#18
	ldi r1,#0
	sth r1,@r4
md_none:
	nop || nop
	nop || nop
	nop || nop
	nop || nop
	nop || nop
