/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
"Boost control: hijack purge PMW [m32r-bl]" update_purge_pwm_call_location : {
	LONG(update_boost_pwm)
}
*/

"Boost control: replace purge PMW" update_purge_pwm : {
	boost_through_purge_pwm.o(.text)
}
