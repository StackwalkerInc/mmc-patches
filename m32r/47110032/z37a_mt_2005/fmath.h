// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef MMC_FIXED_POINT_MATH_H
#define MMC_FIXED_POINT_MATH_H

#include <stdint.h>

#define DECLARE_AXIS(name, _size)                                                                                      \
	const struct name##_type {                                                                                         \
		uint16_t dst;                                                                                                  \
		uint16_t src;                                                                                                  \
		uint16_t size;                                                                                                 \
		uint16_t data[_size];                                                                                          \
	} name

#define DECLARE_2DMAP8(name, _xsize)                                                                                   \
	const struct name##_type {                                                                                         \
		uint8_t type;                                                                                                  \
		uint8_t offset;                                                                                                \
		uint16_t xsrc;                                                                                                 \
		uint8_t data[_xsize];                                                                                          \
	} name
#define DECLARE_2DMAP16(name, _xsize)                                                                                  \
	const struct name##_type {                                                                                         \
		uint16_t type;                                                                                                 \
		uint16_t offset;                                                                                               \
		uint16_t xsrc;                                                                                                 \
		uint16_t data[_xsize];                                                                                         \
	} name
#define DECLARE_3DMAP8(name, _xsize, _ysize)                                                                           \
	const struct name##_type {                                                                                         \
		uint8_t type;                                                                                                  \
		uint8_t offset;                                                                                                \
		uint16_t xsrc;                                                                                                 \
		uint16_t ysrc;                                                                                                 \
		uint8_t xsize;                                                                                                 \
		uint8_t data[_xsize * _ysize];                                                                                 \
	} name

#define TEMP_3DMAP_SRC .type = 3, .xsrc = temp_axis_target_x, .ysrc = temp_axis_target_y
#define TEMP_2DMAP_SRC .type = 2, .xsrc = temp_axis_target_x

#define MAP_AXIS_POINTER(x) (x)

#define TEMP_AXIS_SRC_XDST .dst = temp_axis_target_x, .src = temp_axis_src
#define TEMP_AXIS_SRC_YDST .dst = temp_axis_target_y, .src = temp_axis_src

#define PTL16(percentage) ((uint16_t)(percentage * 32 / 10))
#define RTR16(rpm) ((uint16_t)(rpm * 256 / 1000))
#define VSHIRES(kph) ((uint16_t)(kph * 4))

#define MIN(x, y) (x < y ? x : y)

uint_fast16_t s_add16(uint_fast16_t l, uint_fast16_t r);
uint32_t add16(uint_fast16_t l, uint_fast16_t r);
uint32_t s_add32(uint32_t x, uint32_t y);
void memzero16(uint16_t *begin, uint16_t *end);
void s_dec_u16a_atomic(uint16_t *start, uint16_t *end);
void s_inc_u16a_atomic(uint16_t *start, uint16_t *end);
uint_fast8_t s_16to8(uint_fast16_t v);
uint16_t s_32to16(uint32_t v);
uint16_t mid16(uint16_t x, uint16_t y, uint16_t z);
uint32_t mid32(uint32_t x, uint32_t y, uint32_t z);
uint16_t s_mul_divu16(uint16_t x, uint16_t y, uint16_t z);
uint32_t s_mul32_16_divu16(uint32_t x, uint16_t y, uint16_t z);
uint16_t ps_mul_divu16(uint16_t x, uint16_t y, uint16_t z);
uint32_t ps_mul32_16_divu16(uint32_t x, uint16_t y, uint16_t z);
uint16_t s_scale_base128(uint16_t x, uint16_t y);
uint32_t s32_scale_base128(uint32_t x, uint32_t y);
uint16_t ps_scale_base128(uint16_t x, uint16_t y);
uint32_t ps32_scale_base128(uint32_t x, uint16_t y);
uint16_t s_scale_base256(uint16_t x, uint16_t y);
uint32_t s32_scale_base256(uint32_t x, uint16_t y);
uint16_t ps_scale_base256(uint16_t x, uint16_t y);
uint32_t ps_mul32_16(uint32_t x, uint16_t y);
uint8_t conv8f8_uint(uint16_t x);
uint16_t conv16f16_uint(uint32_t x);
uint16_t conv_u8_8f8(uint8_t x);
uint32_t conv_uint_16f16(uint32_t x);
uint8_t p_conv8f8_u8(uint16_t v);
uint16_t p_conv32_16(uint32_t v);
uint16_t swap_bytes16(uint16_t v);
uint16_t to_g16(uint8_t v);
uint16_t s_divu16(uint16_t l, uint16_t r);
uint16_t s16_divu32_16(uint32_t l, uint16_t r);
uint32_t s32_divu32_16(uint32_t l, uint16_t r);
uint16_t ps_divu16(uint16_t l, uint16_t r);
uint16_t ps16_divu32_16(uint32_t l, uint16_t r);
uint32_t prec_sat32_divu32_16(uint32_t l, uint16_t r);
uint16_t aprxu16_256(uint16_t p0, uint16_t p1, uint16_t rat256); // higher rate - more of p0
uint16_t aprxu32(uint32_t p0, uint32_t p1, uint16_t rat);
uint_fast16_t aprxu16_255(uint16_t p0, uint16_t p1, uint16_t rat255); // higher rate - more of p0
uint32_t p_aprx16f16_255(uint32_t p0, uint32_t p1, uint16_t rat255);

// uint16_t map8u16(const struct map8_desc *ptr);
// uint16_t mapu16(const struct map16_desc *ptr);
// uint16_t multimap8u16(const struct map8_description **ptr);
// uint16_t multimapu16(const struct map16_description **ptr);

uint_fast16_t map8u16(const void *ptr);
uint_fast16_t mapu16(const void *ptr);
uint_fast16_t multimap8u16(const void *ptr);
uint_fast16_t multimapu16(const void *ptr);
uint8_t *multiu8a(uint8_t *const *ptr);
void *multivoidstar(void *const *ptr);
uint8_t multiu8(const uint8_t *ptr);
uint_fast16_t multiu16(const uint16_t *ptr);
uint16_t p_aprxu16_255_2(uint16_t p0, uint16_t p1, uint16_t rate);

// void calc_axis(const struct axis_desc *ptr);

void calc_axis(const void *ptr);

uint16_t s_mul16(uint16_t l, uint16_t r);
uint32_t mul16(uint16_t l, uint16_t r);
uint32_t s_mul32(uint32_t l, uint32_t r);
uint_fast16_t s_sub16(uint_fast16_t l, uint_fast16_t r);
uint32_t s_sub32(uint32_t l, uint32_t r);

#define IN_BOUNDS16(var, low, high) ((readu16(var) >= low) && (readu16(var) <= high))

#endif /*MMC_FIXED_POINT_MATH_H*/
