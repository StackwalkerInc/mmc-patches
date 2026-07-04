#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Validate manifest.toml for cross-ROM collisions and dangling target_dir entries."""
import pathlib
import sys

if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib  # type: ignore[no-redef]


def check(manifest_path: pathlib.Path) -> list[str]:
    violations: list[str] = []
    with open(manifest_path, "rb") as f:
        data = tomllib.load(f)

    roms = data.get("rom", [])
    repo_root = manifest_path.parent

    seen_patched_ids: dict[str, str] = {}
    seen_output_bins: dict[str, str] = {}
    seen_output_xmls: dict[str, str] = {}

    for rom in roms:
        rom_id = rom.get("id", "<missing id>")

        patched_id = rom.get("patched_rom_id_hex")
        if patched_id in seen_patched_ids:
            violations.append(
                f"duplicate patched_rom_id_hex '{patched_id}': "
                f"used by both '{seen_patched_ids[patched_id]}' and '{rom_id}'"
            )
        elif patched_id is not None:
            seen_patched_ids[patched_id] = rom_id

        output_bin = rom.get("output_bin")
        if output_bin in seen_output_bins:
            violations.append(
                f"duplicate output_bin '{output_bin}': "
                f"used by both '{seen_output_bins[output_bin]}' and '{rom_id}'"
            )
        elif output_bin is not None:
            seen_output_bins[output_bin] = rom_id

        output_xml = rom.get("output_xml")
        if output_xml in seen_output_xmls:
            violations.append(
                f"duplicate output_xml '{output_xml}': "
                f"used by both '{seen_output_xmls[output_xml]}' and '{rom_id}'"
            )
        elif output_xml is not None:
            seen_output_xmls[output_xml] = rom_id

        target_dir = rom.get("target_dir")
        if target_dir is not None:
            target_path = repo_root / target_dir
            if not target_path.is_dir():
                violations.append(
                    f"'{rom_id}': target_dir '{target_dir}' does not exist"
                )
            elif not (target_path / "Makefile").is_file():
                violations.append(
                    f"'{rom_id}': target_dir '{target_dir}' has no Makefile"
                )

    return violations


def main() -> int:
    manifest_path = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "manifest.toml")
    if not manifest_path.is_file():
        print(f"ERROR: manifest not found at {manifest_path}", file=sys.stderr)
        return 1

    violations = check(manifest_path)
    if violations:
        print("manifest.toml validation failed:", file=sys.stderr)
        for v in violations:
            print(f"  - {v}", file=sys.stderr)
        return 1

    print(f"manifest.toml OK ({manifest_path})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
