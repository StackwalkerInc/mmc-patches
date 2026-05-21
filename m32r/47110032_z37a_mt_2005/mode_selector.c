// SPDX-License-Identifier: GPL-3.0-or-later
#include "gpio.h"
#include "memaccess.h"
#include "memory_map.h"
#include <stdint.h>

#include "mode_selector.h"

#define ETACS_DATA0_POSITION_LIGHTS 0x04

void update_mode_selector()
{
	if (readu16(age_x1_ignition) < 20) {
		writeu16(0, adc_byte_mode);
		BIT_CLEAR16(mode_selector_flags, MODE_SELECTOR_ACTIVATED | MODE_SELECTOR_ACTIVE);
	} else if ((readu16(age_x1_ignition) < 40) && IS_CLUTCH_DEPRESSED) {
		BIT_SET16(mode_selector_flags, MODE_SELECTOR_ACTIVATED | MODE_SELECTOR_ACTIVE);
	} else if (IS_BIT_SET16(mode_selector_flags, MODE_SELECTOR_ACTIVATED) & !IS_CLUTCH_DEPRESSED) {
		BIT_CLEAR16(mode_selector_flags, MODE_SELECTOR_ACTIVE);
	}

	if (IS_BIT_SET16(mode_selector_flags, MODE_SELECTOR_ACTIVE)) {
		uint16_t l_adc_mode = readu16(adc_byte_mode);
		if (BRAKES_RELEASED) {
			l_adc_mode += 32;
		} else if (ACCELERATOR_RELEASED) {
			l_adc_mode -= 32;
		}
		writeu16(l_adc_mode % 256, adc_byte_mode);
		return;
	}

	if (IS_BIT_SET16(mode_selector_flags, MODE_SELECTOR_POSITION_LIGHTS)) {
		BIT_SET16(mode_selector_flags, MODE_SELECTOR_POSITION_LIGHTS_PREV);
	} else {
		BIT_CLEAR16(mode_selector_flags, MODE_SELECTOR_POSITION_LIGHTS_PREV);
	}
	if (IS_BIT_SET8(can_rx1_data0_u8, ETACS_DATA0_POSITION_LIGHTS)) {
		BIT_SET16(mode_selector_flags, MODE_SELECTOR_POSITION_LIGHTS);
	} else {
		BIT_CLEAR16(mode_selector_flags, MODE_SELECTOR_POSITION_LIGHTS);
	}

	if (IS_CLUTCH_DEPRESSED && IS_BIT_SET16(mode_selector_flags, MODE_SELECTOR_POSITION_LIGHTS_PREV)
	    && !IS_BIT_SET16(mode_selector_flags, MODE_SELECTOR_POSITION_LIGHTS)) {
		writeu16((readu16(adc_byte_mode) + 32) % 256, adc_byte_mode);
		writeu16(80, decays_x1_mode_selector_active2);
		BIT_SET16(mode_selector_flags, MODE_SELECTOR_ACTIVE2);
	}
	if (!readu16(decays_x1_mode_selector_active2)) {
		BIT_CLEAR16(mode_selector_flags, MODE_SELECTOR_ACTIVE2);
	}
}
