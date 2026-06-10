// SPDX-License-Identifier: GPL-3.0-or-later
// Included by dispatch_can.c when FEATURE_OBD_MODE_23 is defined.
// cantx5_data0 declared in including TU.

#define MODE_23_CAN_MAX_BYTES 6

static unsigned mode_23_can(uint8_t *rx)
{
	uint8_t *tx = (uint8_t *)&cantx5_data0;
	uint32_t addr = ((uint32_t)rx[2] << 16) | ((uint32_t)rx[3] << 8) | ((uint32_t)rx[4]);
	uint8_t count = rx[5];
	uint8_t i;

	if (count > MODE_23_CAN_MAX_BYTES) {
		/* NRC 0x14 responseTooLong */
		tx[0] = 0x03;
		tx[1] = 0x7f;
		tx[2] = 0x23;
		tx[3] = 0x14;
		return 3;
	}

	tx[0] = count + 1; /* PCI: service + data length */
	tx[1] = 0x63;      /* positive response (0x23 + 0x40) */
	{
		const uint8_t *src = (const uint8_t *)addr;
		for (i = 0; i < count; ++i)
			tx[2 + i] = src[i];
	}
	return 1;
}
