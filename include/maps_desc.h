// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef META_MAPS_DESC_H
#define META_MAPS_DESC_H

#define _DECLARE_VALUE_DESC(name, category, username, scaling) \
const char __attribute__((section("data_desc"))) DD##name[] = "value;" category ";" username ";" scaling

#define DECLARE_VALUE_DESC(name, category, username, scaling) _DECLARE_VALUE_DESC(name, category, username, scaling)

#define _DECLARE_ARRAY_DESC(name, category, username, scaling, axisdesc) \
const char __attribute__((section("data_desc"))) DD##name[] = "array;" category ";" username ";" scaling ";" axisdesc

#define DECLARE_ARRAY_DESC(name, category, username, scaling, axisdesc) _DECLARE_ARRAY_DESC(name, category, username, scaling, axisdesc)

#define _DECLARE_3DARRAY_DESC(name, category, username, scaling, xaxisdesc, yaxisdesc) \
const char __attribute__((section("data_desc"))) DD##name[] = "3darray;" category ";" username ";" scaling ";" xaxisdesc ";" yaxisdesc

#define DECLARE_3DARRAY_DESC(name, category, username, scaling, xaxisdesc, yaxisdesc) _DECLARE_3DARRAY_DESC(name, category, username, scaling, xaxisdesc, yaxisdesc)

#define _DECLARE_AXIS_DESC_EX(name, username, scaling) \
const char __attribute__((section("data_desc"))) DX##name[] = "axisex;" username ";" scaling

#define DECLARE_AXIS_DESC_EX(name, username, scaling) _DECLARE_AXIS_DESC_EX(name, username, scaling)

#define _DECLARE_AXIS_DESC(name, _size, username, scaling) \
const char __attribute__((section("data_desc"))) DD##name[] = "axis;" username ";" scaling ";" #_size

#define DECLARE_AXIS_DESC(name, _size, username, scaling) _DECLARE_AXIS_DESC(name, _size, username, scaling)

#define DECLARE_AXIS_WITH_DESC(name, _size, username, scaling) \
DECLARE_AXIS_DESC(name, _size, username, scaling); \
DECLARE_AXIS(name, _size)

#define _DECLARE_2DMAP16_DESC(name, category, username, scaling, axisname) \
const char __attribute__((section("data_desc"))) DD##name[] = "2dmap16;" category ";" username ";" scaling ";" axisname; \

#define DECLARE_2DMAP16_DESC(name, category, username, scaling, axisname) \
_DECLARE_2DMAP16_DESC(name, category, username, scaling, axisname)


#define _DECLARE_2DMAP8_DESC(name, category, username, scaling, axisname) \
const char __attribute__((section("data_desc"))) DD##name[] = "2dmap8;" category ";" username ";" scaling ";" axisname; \

#define DECLARE_2DMAP8_DESC(name, category, username, scaling, axisname) \
_DECLARE_2DMAP8_DESC(name, category, username, scaling, axisname)

#define _DECLARE_3DMAP8_DESC(name, category, username, scaling, xaxisname, yaxisname) \
const char __attribute__((section("data_desc"))) DD##name[] = "3dmap8;" category ";" username ";" scaling ";" xaxisname ";" yaxisname; \

#define DECLARE_3DMAP8_DESC(name, category, username, scaling, xaxisname, yaxisname) \
_DECLARE_3DMAP8_DESC(name, category, username, scaling, xaxisname, yaxisname)

#define _DECLARE_3DMAP16_DESC(name, category, username, scaling, xaxisname, yaxisname) \
const char __attribute__((section("data_desc"))) DD##name[] = "3dmap16;" category ";" username ";" scaling ";" xaxisname ";" yaxisname; \

#define DECLARE_3DMAP16_DESC(name, category, username, scaling, xaxisname, yaxisname) \
_DECLARE_3DMAP16_DESC(name, category, username, scaling, xaxisname, yaxisname)

#define DECLARE_2DMAP8_WITH_DESC(name, size, category, username, scaling, axisname) \
DECLARE_2DMAP8_DESC(name, category, username, scaling, axisname); \
DECLARE_2DMAP8(name, size)

#define DECLARE_3DMAP8_WITH_DESC(name, _xsize, _ysize, category, username, scaling, xaxisname, yaxisname) \
DECLARE_3DMAP8_DESC(name, category, username, scaling, xaxisname, yaxisname); \
DECLARE_3DMAP8(name, _xsize, _ysize)

#define DECLARE_3DMAP16_WITH_DESC(name, _xsize, _ysize, category, username, scaling, xaxisname, yaxisname) \
DECLARE_3DMAP16_DESC(name, category, username, scaling, xaxisname, yaxisname); \
DECLARE_3DMAP16(name, _xsize, _ysize)

#define DECLARE_2DMAP16_WITH_DESC(name, _xsize, category, username, scaling, xaxisname) \
DECLARE_2DMAP16_DESC(name, category, username, scaling, xaxisname); \
DECLARE_2DMAP16(name, _xsize)

/* Build-time seeding: codeinjector fills the body (and every structural
   field) from the stock ROM, so the C carries only names and dimensions.
   Record layout must match codeinjector's src/seed.rs: 16 bytes,
   { u32 kind; u32 dst; u32 src; u32 src_yaxis }. */
#define SEED_KIND_AXIS    1
#define SEED_KIND_MAP3D8  2

struct seed_record {
	unsigned long kind;
	const void *dst;
	const void *src;
	const void *src_yaxis;
};

#define _DECLARE_SEED(name, kind, stock, stock_yaxis)                                                                  \
	const struct seed_record __attribute__((section("data_seed"))) DS##name = {                                        \
	    (kind), (const void *)&name, (const void *)(stock), (const void *)(stock_yaxis)}

#define DECLARE_AXIS_SEEDED(name, _size, username, scaling, stock_axis)                                                \
	DECLARE_AXIS_DESC(name, _size, username, scaling);                                                                 \
	DECLARE_AXIS(name, _size) = {0};                                                                                   \
	_DECLARE_SEED(name, SEED_KIND_AXIS, stock_axis, 0)

#define DECLARE_3DMAP8_SEEDED(name, _xsize, _ysize, category, username, scaling, xaxisname, yaxisname, stock_map,       \
                              stock_yaxis)                                                                             \
	DECLARE_3DMAP8_DESC(name, category, username, scaling, xaxisname, yaxisname);                                      \
	DECLARE_3DMAP8(name, _xsize, _ysize) = {0};                                                                        \
	_DECLARE_SEED(name, SEED_KIND_MAP3D8, stock_map, stock_yaxis)

#endif /*META_MAPS_DESC_H*/
