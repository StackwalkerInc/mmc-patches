// SPDX-License-Identifier: GPL-3.0-or-later
// Included by dispatch_kline.c when FEATURE_OBD_VIN_GUARD is defined.
// VIN_SIZE, vin[], shadow_vin[], vin_volatility, flash_vin_signature,
// flash_key_moduli declared in vin_guard_data.c (included before this file).
#include <stdint.h>
#include "../powmod.h"

extern uint32_t TML0CT;
extern uint16_t age_x1_ignition;
extern uint16_t decays_x1_signature;

extern unsigned get_ig1();
extern void regen_crankshaft_rotation_decays();
extern void cruise_control(void);

// clang-format off
#define CHECK_G16(x) ((x & 0xff) == (((~x) >> 8) & 0xff))
#define WRITE_G16(x, v) do { x = (v & 0xff) | (((~v) << 8) & 0xff00); } while (0)
#define READ_G16(x) (x & 0xff)
// clang-format on

static void generate_new_vin()
{
	do {
		int i = 0;
		unsigned ct = TML0CT * 1664525 + 1013904223;
		uint8_t *ct_ptr = (uint8_t *)&ct;
		for (i = 0; i < VIN_SIZE; ++i) {
			vin[i] = ct_ptr[i];
			shadow_vin[i] = ~vin[i];
		}
		WRITE_G16(vin_volatility, 1);
	} while (!vin[0] && !vin[1] && !vin[2] && !vin[3]);
}

static unsigned check_vin_correctness()
{
	int i = 0;
	for (i = 0; i < VIN_SIZE; ++i) {
		if ((~shadow_vin[i] & 0xff) != vin[i]) {
			WRITE_G16(vin_volatility, 1);
			return 0;
		}
	}
	if (!CHECK_G16(vin_volatility)) {
		WRITE_G16(vin_volatility, 0);
	}
	if (READ_G16(vin_volatility))
		return 0;
	return 1;
}

static unsigned ensure_vin_correctness()
{
	if (!check_vin_correctness()) {
		generate_new_vin();
		return 0;
	}
	if (READ_G16(vin_volatility))
		return 0;
	return 1;
}

static void mode_a1_kline(void)
{
	switch (sio0_rx_buffer[4]) {
	case 1: /* code status */
		if (ensure_vin_correctness()) {
			sio0_tx_buffer[4] = 1;
		} else {
			sio0_tx_buffer[4] = 2;
		}
		sio0_tx_count = 6;
		break;
	case 2: /* vin */
		if (!check_vin_correctness()) {
			break;
		}
		sio0_tx_buffer[4] = vin[0];
		sio0_tx_buffer[5] = vin[1];
		sio0_tx_buffer[6] = vin[2];
		sio0_tx_buffer[7] = vin[3];
		sio0_tx_count = 9;
		break;
	default:
		break;
	}
}

#define PUBLIC_EXP 17

unsigned signature_check()
{
	int i = 0;
	if (!check_vin_correctness())
		return 0;
	for (i = 0; i < VIN_SIZE; ++i) {
		unsigned ch = powmod(flash_vin_signature[i], PUBLIC_EXP, flash_key_moduli[i]);
		if (ch != vin[i])
			return 0;
	}
	return 1;
}

static const uint16_t flash_prestart_vin_checks = 40;
static const uint16_t flash_signature_validity = 80;

void prestart_checks()
{
	if (age_x1_ignition < flash_prestart_vin_checks / 2) {
		decays_x1_signature = 0;
	} else if (age_x1_ignition < flash_prestart_vin_checks) {
		if (signature_check())
			decays_x1_signature = flash_signature_validity;
	} else if (get_ig1() && decays_x1_signature) {
		decays_x1_signature = flash_signature_validity;
	}

	cruise_control();
}

void injected_regen_crankshaft_rotation_decays()
{
	if (decays_x1_signature)
		regen_crankshaft_rotation_decays();
}
