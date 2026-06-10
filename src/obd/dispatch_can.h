// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef OBD_DISPATCH_CAN_H
#define OBD_DISPATCH_CAN_H

/* CAN injection point: trampoline over canrx12_15_process.
 * slot==2 -> canrx12_data (physical 0x7E0), else canrx15_data (functional 0x7DF).
 * Returns r5 response code (1=positive, 3=negative). */
unsigned canrx12_15_process_trampoline(unsigned slot);

#endif /* OBD_DISPATCH_CAN_H */
