// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef CAN_LOG_TIME_BASED_H
#define CAN_LOG_TIME_BASED_H

struct can_log_time_based_item {
	void *ptr;
	uint8_t size;
	uint8_t padding[3];
}

struct can_log_time_based_message_definition {
	struct can_log_time_based_item items[7];
};

struct can_log_time_based_instance {
	struct can_log_time_based_message_definition messages[8];
	uint16_t transmission_interval;
	uint16_t transmission_decay;
	uint8_t frequency_id;
	uint8_t mesage_count;
	uint8_t state;
	uint8_t padding;
};

#endif /*CAN_LOG_TIME_BASED_H*/
