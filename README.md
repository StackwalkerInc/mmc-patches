# mmc-patches

Code-injection patches for Mitsubishi M32R ECUs, targeting the Colt Ralliart (Z27AG) family.

Patches are distributed as source + EcuFlash XML. You supply the stock ROM; the build
applies the patches and produces a ready-to-flash `.bin` and an EcuFlash `.xml` definition.

## Supported ROMs

| ROM ID     | Vehicle                             | Arch  |
|------------|-------------------------------------|-------|
| `3352a403` | Colt Ralliart Z27AG JDM 5MT 2006–08 | M32R  |

## Build environment

The canonical build environment is
[`ghcr.io/rcusstackwalker/m32r-injector-toolchain`](https://github.com/RcusStackwalker/m32r-injector-toolchain),
which bundles `m32r-elf-gcc`, `m32r-elf-ld`, and `codeinjector`.

No local toolchain installation required — Docker is the only prerequisite.

## Building

1. Obtain your stock ROM (e.g. via livemonitor or EcuFlash read).
2. Place it in `roms/`:

   ```sh
   mkdir -p roms
   cp /path/to/Z27AG_JDM_5MT_1860B104.bin roms/
   ```

3. Run the build inside the Docker image:

   ```sh
   make docker
   ```

   Or pass `ROM_DIR` explicitly:

   ```sh
   docker run --rm -v "$PWD:/work" -w /work \
     ghcr.io/rcusstackwalker/m32r-injector-toolchain:latest \
     make ROM_DIR=/work/roms OUT_DIR=/work/out
   ```

4. Output lands in `out/`:
   - `3352a403_patched.bin` — flash this with EcuFlash + OpenPort 2.0
   - `3352a403.xml` — EcuFlash definition (load alongside the patched ROM)

   EcuFlash kernel selection: **"Lancer RalliArt 512K M32176F4"**
   (the Colt-specific kernel has bugs; use the Lancer kernel).

## Using a pre-built ELF from a release

Each [release](../../releases) attaches compiled ELF files. If you have the Docker image
and stock ROM you can skip building from source and patch directly:

```sh
docker run --rm -v "$PWD:/work" -w /work \
  ghcr.io/rcusstackwalker/m32r-injector-toolchain:latest \
  sh -c 'codeinjector mmc-m32r roms/Z27AG_JDM_5MT_1860B104.bin \
         3352a403.elf out/3352a403_patched.bin > out/3352a403_patches.xml'
```

Then assemble the full EcuFlash XML:

```sh
printf '<rom>\n' > out/3352a403.xml
cat m32r/33520003_z27ag_mt_2006/3352a403_header.xml >> out/3352a403.xml
cat out/3352a403_patches.xml >> out/3352a403.xml
printf '</rom>\n' >> out/3352a403.xml
```

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
manifest.toml     ROM registry: SHA-256, filenames, output IDs
roms/             (gitignored) place your stock ROM here
out/              (gitignored) patched output
.github/
  workflows/
    pr.yml        compile all targets on every PR
    release.yml   compile + publish ELF artifacts on version tag
```

## CI

Every pull request compiles all ROM targets inside the Docker image. No ROMs are
present in CI — the compile step builds to ELF, verifying source correctness.

To publish a release: push a version tag (`v1.0.0`). The release workflow compiles
all targets and attaches the ELF files to a GitHub release.

## IP notice

Patches and source are original work, distributed under the project license.
Stock ROM binaries are Mitsubishi's IP and are **never** distributed here.
