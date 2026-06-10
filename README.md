# mmc-patches

Code-injection patches for Mitsubishi M32R ECUs, targeting Colt, Evo X, Eclipse, Outlander,
Pajero iO, and Pajero Sport ECU families.

Patches are distributed as source + EcuFlash XML. You supply the stock ROM; the build
applies the patches and produces a ready-to-flash `.bin` and an EcuFlash `.xml` definition.

## Supported ROMs

| Stock ROM ID | Patched ROM ID | Vehicle                                              | MCU        |
|--------------|----------------|------------------------------------------------------|------------|
| `33520003`   | `3352a403`     | Colt Ralliart Version-R Z27AG JDM 5MT (2006–2008)    | M32170F6   |
| `33520003`   | `3352a3a3`     | Colt Ralliart Version-R Z27AG JDM 5MT — slim variant | M32170F6   |
| `35740031`   | —              | Colt Ralliart Z27A JDM CVT 1.5T (2005)               | M32170F6   |
| `39670016`   | `3967a016`     | Colt Ralliart Z27A AUDM 5MT (2008)                   | M32170F6   |
| `47110032`   | `4711a032`     | Colt CZT Z37A 1.5T 5MT (2005)                        | M32176F3   |
| `53040110`   | —              | Lancer Evo X CZ4A EDM 5MT — Tephra XMOD base         | M32186F8   |
| `53050009`   | `5305a009`     | Lancer Evo X CZ4A EDM SST (Kiwamaru)                 | M32186F8   |
| `8631B019`   | —              | Pajero Sport Diesel AT ECU (KMD50301)                | M32176F4   |
| `b2940007`   | `b294a007`     | Eclipse 4G USDM 4G69 5MT (2008)                      | M32176F4   |
| `c6660015`   | `c666a015`     | Pajero iO 4G94 GDI (early 2000s)                     | M32176F4   |
| `c7280011`   | `c728a311`     | Outlander CU2W 4G63T (Nameless-prepped, 2007)        | M32176F4   |

**Stock ROM ID** is the ID embedded in the factory ROM (at offset 0xE2).
**Patched ROM ID** is the new ID written by the patch via `ReplaceROMID`, so EcuFlash loads the patched XML definition only against the patched ROM and never against a stock ROM. A `—` means the ROM ID is unchanged (no `ReplaceROMID` patch applied).

## Build environment

The canonical build environment is
[`ghcr.io/rcusstackwalker/m32r-injector-toolchain`](https://github.com/RcusStackwalker/m32r-injector-toolchain),
which bundles `m32r-elf-gcc`, `m32r-elf-ld`, and `codeinjector`.

No local toolchain installation required — Docker is the only prerequisite.

## Building

The example below uses the Z27AG JDM 5MT (33520003) as the reference ROM. For other
ROMs, substitute the filename and output IDs from `manifest.toml`.

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

   EcuFlash kernel selection for Z27AG/Z27A (M32170F6): **"Lancer RalliArt 512K M32176F4"**
   (the Colt-specific kernel has bugs; use the Lancer kernel).

## Using a pre-built ELF from a release

Each [release](../../releases) attaches compiled ELF files. If you have the Docker image
and stock ROM you can skip building from source and patch directly (example for Z27AG):

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

Substitute the ROM-specific filenames from `manifest.toml` for other targets.

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
  33520003_z27ag_mt_2006/     Z27AG JDM 5MT full patch set
  3352a3a3_z27ag_mt_2006/     Z27AG JDM 5MT slim variant
  35740031_z27a_cvt_2005/     Z27A JDM CVT
  39670016_z27a_mt_audm/      Z27A AUDM 5MT
  47110032_z37a_mt_2005/      Colt CZT Z37A
  53040110_cz4a_mt_edm_Tephra/  Evo X CZ4A 5MT (Tephra)
  53050009_cz4a_sst_edm/      Evo X CZ4A SST (Kiwamaru)
  8631B0190A_pajero_sport_at/ Pajero Sport Diesel AT
  b2940007_eclipse_mt_2008/   Eclipse 4G USDM 5MT
  c6660015_pajero_io_4g94gdi/ Pajero iO 4G94 GDI
  c728001x_cu2w_outlander_turbo/  Outlander CU2W turbo
  (each ROM dir contains Makefile, omni.ld, description.ld, per-ROM sources,
   and a *_header.xml EcuFlash ROM definition header)
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
