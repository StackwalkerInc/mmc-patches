# mmc-patches

Code-injection patches for Mitsubishi M32R ECUs, targeting the Colt Ralliart (Z27AG) family.

Patches are distributed as source + EcuFlash XML. You supply the stock ROM; the build
applies the patches and produces a ready-to-flash `.bin` and an EcuFlash `.xml` definition.

## Supported ROMs

| ROM ID     | Vehicle                             | Arch  |
|------------|-------------------------------------|-------|
| `3352a403` | Colt Ralliart Z27AG JDM 5MT 2006–08 | M32R  |

## Build environment

The canonical build environment is the
[m32r-injector-toolchain](https://github.com/RcusStackwalker/m32r-injector-toolchain)
Docker image, which bundles `m32r-elf-gcc`, `m32r-elf-ld`, and the host `gcc`/`libbfd`
needed to compile codeinjector.

```sh
docker run --rm -v $(pwd):/work -w /work m32r-injector-toolchain make
```

Without Docker: install `m32r-elf-binutils`, `m32r-elf-gcc` (≤ 8.x), and `libbfd-dev`
manually, then run `make` directly.

## Building

1. Obtain your stock ROM (e.g. via livemonitor or EcuFlash read).
2. Place it in `roms/`:

   ```sh
   mkdir -p roms
   cp /path/to/Z27AG_JDM_5MT_1860B104.bin roms/
   ```

3. Build codeinjector (first time only):

   ```sh
   make codeinjector
   ```

4. Build the Z27AG patchset:

   ```sh
   make z27ag
   ```

   Or pass `ROM_DIR` explicitly if your ROM lives elsewhere:

   ```sh
   make z27ag ROM_DIR=/path/to/roms
   ```

5. Output lands in `out/`:
   - `3352a403_patched.bin` — flash this with EcuFlash + OpenPort 2.0
   - `3352a403.xml` — EcuFlash definition (load alongside the patched ROM)

   EcuFlash kernel selection: **"Lancer RalliArt 512K M32176F4"**
   (the Colt-specific kernel has bugs; use the Lancer kernel).

## ROM verification

The build checks the SHA-256 of your stock ROM before patching. If the check fails,
the ROM is either wrong or corrupted — don't flash it.

Expected SHA-256 values are in `manifest.toml`.

## Repository layout

```
include/          shared headers (M32R variable maps, peripheral defs)
src/              shared C patch modules
m32r/
  toolchain.mk    compiler/linker settings
  *.ld            shared linker fragments (math library, load400, nlts, …)
  33520003_z27ag_mt_2006/
    Makefile
    omni.ld       ROM-specific linker script (patch addresses, free space)
    description.ld  ROM-specific symbol definitions
    precision_boost.c  per-ROM source
    3352a403_header.xml  EcuFlash ROM definition header
tools/codeinjector/  C codeinjector source (reads ELF, emits XML patches)
manifest.toml     ROM registry: SHA-256, filenames, output IDs
roms/             (gitignored) place your stock ROM here
out/              (gitignored) patched output
```

## IP notice

Patches and source are original work, distributed under the project license.
Stock ROM binaries are Mitsubishi's IP and are **never** distributed here.
