// SPDX-License-Identifier: GPL-3.0-or-later
// Included by dispatch_kline.c when FEATURE_OBD_MODE_3D is defined.
// sio0_rx_buffer, sio0_tx_count declared in including TU.
// No bounds check on address — same policy as mode 23. Flash writes silently fail.

#define MODE_3D_KLINE_MAX_BYTES 7

static void mode_3d_kline(void)
{
	uint32_t addr = ((uint32_t)(sio0_rx_buffer[4] & 0xff) << 16) | ((uint32_t)(sio0_rx_buffer[5] & 0xff) << 8)
	                | ((uint32_t)(sio0_rx_buffer[6] & 0xff));
	uint8_t count = sio0_rx_buffer[7] & 0xff;
	uint8_t *dst = (uint8_t *)addr;
	uint8_t i;

	if (count > MODE_3D_KLINE_MAX_BYTES)
		count = MODE_3D_KLINE_MAX_BYTES;

	for (i = 0; i < count; ++i)
		dst[i] = sio0_rx_buffer[8 + i] & 0xff;

	/* Positive response: stock framing sets sio0_tx_buffer[3] = 0x7D;
	 * no echoed data needed. */
	sio0_tx_count = 4;
}
