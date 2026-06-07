// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef OBD_MODE23_H
#define OBD_MODE23_H

#include <stdint.h>

/* Max data bytes returnable per transport.
 * K-Line: sio0_tx_buffer is uint16_t[15]; data goes in slots [4..], the stock
 *         handler appends a checksum at [4+count], so count must be <= 10.
 * CAN:    single-frame, DLC=8: 1 PCI + 1 service byte + up to 6 data bytes.
 */
#define MODE23_KLINE_MAX_BYTES 10
#define MODE23_CAN_MAX_BYTES 6

/* K-Line: called from obd_rest_handler's case 0x23.
 * Reads address/count from sio0_rx_buffer, writes bytes into sio0_tx_buffer,
 * sets sio0_tx_count. */
void obd_mode23_kline(void);

/* CAN: trampoline that replaces the call to canrx12_15_process.
 * Handles service 0x23 itself, otherwise tail-calls the original dispatcher.
 * Returns the r5 response code (1 = positive, 3 = negative). */
unsigned canrx12_15_process_trampoline(void);

#endif /* OBD_MODE23_H */
