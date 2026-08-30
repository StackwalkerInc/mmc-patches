// SPDX-License-Identifier: GPL-3.0-or-later
/* Confirms the selected map profile on the tachometer. Runs on every mode
   change regardless of engine state, for the length of the CEL flash window,
   so an in-motion switch is visible. Z37A has no engine_rpm_hires -- the
   cluster is CAN-driven -- so this overwrites the tach field of the outbound
   frame after the stock per-iteration engine-state recalculation has run.

   Field derivation (Task 5 Step 1, see description.ld for the full writeup):
   cantx_engine_rpm binds to engine_rpm_direct_bound (fp-9906 = 0x80594E),
   NOT to anything computed inside can0_update_tx_data() -- that function
   builds unrelated cantx_* fields (target idle rpm, ASC lamp, coolant temp,
   fan command) and never touches engine speed. The actual dash tach byte
   pair is assembled later, on its own schedule, by can_tx2_id3_dash_update()
   (0x2c738: "can_tx2_id3_source[1] = (engine_rpm_direct_bound >> 8) & 0xff;
   can_tx2_id3_source[2] = engine_rpm_direct_bound & 0xff;"), which reads
   engine_rpm_direct_bound directly -- so that RAM variable, not the
   transient per-message byte buffer, is the right thing to override:
   overwriting it here (every call, for the whole CEL-flash window) reaches
   can_tx2_id3_dash_update() on whatever cadence it next runs.

   engine_rpm_direct_bound carries real, unscaled RPM (not
   RPM_TO_HIRESTICKS ticks), so flash_mode_change_rpm_indication's hires-tick
   values are converted back to plain RPM here: x / 2.048 == x * 125 / 256
   exactly (2.048 == 256/125), which round-trips RPM_TO_HIRESTICKS(2500) and
   RPM_TO_HIRESTICKS(5000) back to 2500 and 5000 exactly. That shared table
   stays untouched -- it is also linked by the bench-qualified 33520003
   target, where it is consumed directly in hires-tick form. */
#include <stdint.h>

extern void can0_update_bus_state(void);
extern void can0_update_tx_data(void);

extern uint16_t cantx_engine_rpm;
extern uint16_t new_mode_idx;
extern uint16_t decays_x1_alt_mode_change_cel_flash_timer;
extern const uint16_t flash_mode_change_rpm_indication[];

void can_topcall_replacement_z37a(void)
{
	can0_update_bus_state();
	can0_update_tx_data();

	if (decays_x1_alt_mode_change_cel_flash_timer) {
		uint16_t hires_ticks = flash_mode_change_rpm_indication[new_mode_idx ? 1 : 0];
		cantx_engine_rpm = (uint16_t)(((uint32_t)hires_ticks * 125u) / 256u);
	}
}
