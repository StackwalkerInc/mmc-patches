# SPDX-License-Identifier: GPL-3.0-or-later
CC=m32r-elf-gcc
LD=m32r-elf-ld

# TOP points from the including leaf directory back to the mmc-patches
# repo root. Leaves at the legacy 2-level depth (m32r/<flat>/) get this
# default; leaves nested one level deeper (m32r/<romid>/<variant>/) set
# TOP := ../../.. before including this file (directly or via their
# per-ROM common.mk).
TOP ?= ../..

DEFINES = -DARCH_M32R=1

CFLAGS = -nostdlib -I./ -I$(TOP)/include -I$(TOP)/include/m32r -I$(TOP)/include/mods -Os -ffixed-r13 -fno-leading-underscore -fcommon
LFLAGS = -T omni.ld

CODEINJECTOR=codeinjector
