# SPDX-License-Identifier: GPL-3.0-or-later
import pathlib
import subprocess
import sys
import tempfile
import textwrap

import check_manifest

GOOD_MANIFEST = textwrap.dedent("""\
    [[rom]]
    id = "rom_a"
    stock_rom_id_hex = "11110000"
    patched_rom_id_hex = "1111a000"
    target_dir = "m32r/11110000/variant_a"
    output_bin = "1111a000_patched.bin"
    output_xml = "1111a000.xml"

    [[rom]]
    id = "rom_b"
    stock_rom_id_hex = "11110000"
    patched_rom_id_hex = "1111a001"
    target_dir = "m32r/11110000/variant_b"
    output_bin = "1111a001_patched.bin"
    output_xml = "1111a001.xml"
    """)

DUPLICATE_ID_MANIFEST = GOOD_MANIFEST.replace(
    'patched_rom_id_hex = "1111a001"', 'patched_rom_id_hex = "1111a000"'
)

DUPLICATE_OUTPUT_MANIFEST = GOOD_MANIFEST.replace(
    'output_bin = "1111a001_patched.bin"', 'output_bin = "1111a000_patched.bin"'
)

MISSING_DIR_MANIFEST = GOOD_MANIFEST.replace(
    'target_dir = "m32r/11110000/variant_b"',
    'target_dir = "m32r/11110000/does_not_exist"',
)


def _write_manifest_and_dirs(tmp_path: pathlib.Path, manifest_text: str) -> pathlib.Path:
    manifest_path = tmp_path / "manifest.toml"
    manifest_path.write_text(manifest_text)
    for variant in ("variant_a", "variant_b"):
        d = tmp_path / "m32r" / "11110000" / variant
        d.mkdir(parents=True, exist_ok=True)
        (d / "Makefile").write_text("# stub\n")
    return manifest_path


def test_good_manifest_passes(tmp_path):
    manifest_path = _write_manifest_and_dirs(tmp_path, GOOD_MANIFEST)
    assert check_manifest.check(manifest_path) == []


def test_duplicate_patched_rom_id_fails(tmp_path):
    manifest_path = _write_manifest_and_dirs(tmp_path, DUPLICATE_ID_MANIFEST)
    violations = check_manifest.check(manifest_path)
    assert any("patched_rom_id_hex" in v and "1111a000" in v for v in violations)


def test_duplicate_output_bin_fails(tmp_path):
    manifest_path = _write_manifest_and_dirs(tmp_path, DUPLICATE_OUTPUT_MANIFEST)
    violations = check_manifest.check(manifest_path)
    assert any("output_bin" in v and "1111a000_patched.bin" in v for v in violations)


def test_missing_target_dir_fails(tmp_path):
    manifest_path = _write_manifest_and_dirs(tmp_path, MISSING_DIR_MANIFEST)
    violations = check_manifest.check(manifest_path)
    assert any("does_not_exist" in v for v in violations)


def test_missing_makefile_fails(tmp_path):
    manifest_path = _write_manifest_and_dirs(tmp_path, GOOD_MANIFEST)
    (tmp_path / "m32r" / "11110000" / "variant_b" / "Makefile").unlink()
    violations = check_manifest.check(manifest_path)
    assert any("Makefile" in v for v in violations)


def test_cli_exits_nonzero_on_violation(tmp_path):
    manifest_path = _write_manifest_and_dirs(tmp_path, DUPLICATE_ID_MANIFEST)
    result = subprocess.run(
        [sys.executable, str(pathlib.Path(__file__).parent / "check_manifest.py"), str(manifest_path)],
        capture_output=True,
        text=True,
    )
    assert result.returncode == 1
    assert "patched_rom_id_hex" in result.stderr


def test_cli_exits_zero_on_success(tmp_path):
    manifest_path = _write_manifest_and_dirs(tmp_path, GOOD_MANIFEST)
    result = subprocess.run(
        [sys.executable, str(pathlib.Path(__file__).parent / "check_manifest.py"), str(manifest_path)],
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0
