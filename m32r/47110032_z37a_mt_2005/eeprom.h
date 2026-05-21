// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef MMC_EEPROM_H
#define MMC_EEPROM_H

#define EERPOM0_I2C_FAIL 0x0001
#define EERPOM0_DATA1_RAM_MISMATCH 0x0002
#define EERPOM0_DATA2_CRC_FAIL 0x0004
// #define EERPOM0_FAILURE			0x0008
// #define EERPOM0_FAILURE			0x0010
// #define EERPOM0_FAILURE			0x0020
#define EERPOM0_HEADER_CRC_FAIL 0x0040
#define EERPOM0_DATA1_CRC_FAIL 0x0080
#define EERPOM0_DATA2_INTACT 0x0100
// #define EERPOM0_FAILURE			0x0200
// #define EERPOM0_FAILURE			0x0400
// #define EERPOM0_FAILURE			0x0800
// #define EERPOM0_FAILURE			0x1000
// #define EERPOM0_FAILURE			0x2000
// #define EERPOM0_FAILURE			0x4000
#define EERPOM0_HEADER_INVALID 0x8000

#define EERPOM1_CAN_REPORT_FAULT_STATE 0x2000

/*these three command loop*/
#define EERPOM2_NEXT_WRITE_BLOCK 0x0001
#define EERPOM2_NEXT_SETRESET 0x0002
#define EERPOM2_NEXT_MATCH_TO_RAM 0x0004

#define EERPOM2_FAULTS0H01FF_RESET_DONE 0x8000

void eeprom_match_to_mem();

struct eeprom_data1 {
	uint8_t some_data[10];  // offset 0 - combined 0x500ca data, rom versions
	uint8_t hw_part_id[10]; // offset 10 - presumed by ecuflash connected to 0x500d4 data
	uint8_t vin_oem[17];    // offset 20
	uint8_t some_data[4];   // offset 37
	uint8_t vin[17];        // offset 41
	uint8_t some_data[8];   // offset 58, written at the same time as off90

	uint16_t rom_version0;  // offset 71
	uint8_t rom_version1;   // offset 73
	uint8_t sw_part_id[10]; // offset 74 - presumed by ecuflash connected to 0x500de data

	uint8_t enforce_bootloader_loop_for_reflash; // offset 90
	uint8_t some_data[5];                        // offset 91
	uint8_t calid[11];                           // offset 96, first 5 bytes BCD
}

extern uint16_t eeprom_block;
extern uint8_t eeprom_data_area[512];
extern uint16_t eeprom_flags[3];

#endif /*MMC_EEPROM_H*/
