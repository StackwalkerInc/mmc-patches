// SPDX-License-Identifier: GPL-3.0-or-later
#include <stdint.h>

extern void update_purge_control_solenoid_duty(uint_fast16_t val, uint_fast16_t tmax, uint_fast16_t valmax);
extern uint16_t wastegate_solenoid_duty;

void update_purge_solenoid_duty_from_wastegate(void)
{
	update_purge_control_solenoid_duty(wastegate_solenoid_duty, 25000, 200);
}
