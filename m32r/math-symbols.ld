/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Stock math/map library as offsets from three bases; include m32r/math.ld
   for the stock 33520003-family addresses. */

/* push/pop interrupt-state helpers -- offsets from MATH_PUSHI_BASE */
pushi = MATH_PUSHI_BASE + 0x000;
popi  = MATH_PUSHI_BASE + 0x018;

/* scalar helpers -- offsets from MATH_BASE */
s_add16           = MATH_BASE + 0x000;
add16             = MATH_BASE + 0x014;
s_add32           = MATH_BASE + 0x020;
s_dec_u16a_atomic = MATH_BASE + 0x040;
s_16to8           = MATH_BASE + 0x094;
s_32to16          = MATH_BASE + 0x0a8;
mid16             = MATH_BASE + 0x0b8;
mid32             = MATH_BASE + 0x0e4;
s_mul_divu16      = MATH_BASE + 0x104;
s_mul32_16_divu16 = MATH_BASE + 0x128;
ps_mul_divu16     = MATH_BASE + 0x174;
s32_scale_base128 = MATH_BASE + 0x204;
ps_scale_base128  = MATH_BASE + 0x23c;
s_scale_base256   = MATH_BASE + 0x290;
s32_scale_base256 = MATH_BASE + 0x2a8;
ps_scale_base256  = MATH_BASE + 0x2e0;
conv16to8         = MATH_BASE + 0x33c;
p_conv32_16       = MATH_BASE + 0x378;
s_divu16          = MATH_BASE + 0x3c8;
s16_divu32_16     = MATH_BASE + 0x3e8;
ps_divu16         = MATH_BASE + 0x41c;
ps16_divu32_16    = MATH_BASE + 0x440;
aprxu16_255       = MATH_BASE + 0x554;
s_mul16           = MATH_BASE + 0x910;
mul16             = MATH_BASE + 0x924;
s_sub16           = MATH_BASE + 0x980;
s_sub32           = MATH_BASE + 0x998;

/* map / axis lookup -- offsets from MATH_MAP_BASE */
map8u16      = MATH_MAP_BASE + 0x000;
mapu16       = MATH_MAP_BASE + 0x0d0;
multimap8u16 = MATH_MAP_BASE + 0x188;
multiu8      = MATH_MAP_BASE + 0x1d8;
multiu16     = MATH_MAP_BASE + 0x1e8;
calc_axis    = MATH_MAP_BASE + 0x268;
