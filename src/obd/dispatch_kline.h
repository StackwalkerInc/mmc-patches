// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef OBD_DISPATCH_KLINE_H
#define OBD_DISPATCH_KLINE_H

/* K-Line injection point: replaces lduh r0,@(sio0_tx_count,fp) in the stock
 * K-Line rest-handler path. Returns sio0_tx_count. */
unsigned obd_kline_rest_handler(void);

#endif /* OBD_DISPATCH_KLINE_H */
