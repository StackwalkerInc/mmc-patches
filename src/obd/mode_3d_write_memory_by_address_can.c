// SPDX-License-Identifier: GPL-3.0-or-later
// Included by dispatch_can.c when FEATURE_OBD_MODE_3D is defined.
// cantx5_data0 declared in including TU.
// Single-frame only; count > 2 would require multi-frame which is not supported.

#define MODE_3D_CAN_MAX_BYTES 2

static unsigned mode_3d_can(uint8_t *rx)
{
	uint8_t *tx = (uint8_t *)&cantx5_data0;
	uint32_t addr = ((uint32_t)rx[2] << 16) | ((uint32_t)rx[3] << 8) | ((uint32_t)rx[4]);
	uint8_t count = rx[5];
	uint8_t *dst = (uint8_t *)addr;
	uint8_t i;

	if (count > MODE_3D_CAN_MAX_BYTES) {
		/* NRC 0x13 incorrectMessageLengthOrInvalidFormat */
		tx[0] = 0x03;
		tx[1] = 0x7f;
		tx[2] = 0x3d;
		tx[3] = 0x13;
		return 3;
	}

	for (i = 0; i < count; ++i)
		dst[i] = rx[6 + i];

	tx[0] = 0x01; /* PCI: 1 payload byte */
	tx[1] = 0x7d; /* positive response (0x3D + 0x40) */
	return 1;
}
