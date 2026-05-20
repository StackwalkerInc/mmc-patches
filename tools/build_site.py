#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Build site/index.html from manifest.toml."""

import html
import json
import pathlib
import sys
import tomllib  # stdlib since Python 3.11

CATEGORY_LABELS = {
    "engine":         "Engine",
    "boost":          "Boost",
    "rev-limit":      "Rev Limit",
    "knock":          "Knock",
    "multimap":       "Multi-Map",
    "qol":            "QoL",
    "obd":            "OBD",
    "dash":           "Dash",
    "infrastructure": "Infrastructure",
}

PATCH_COLUMNS = [
    ("Patch",        "name",        False),
    ("Category",     "category",    True),
    ("Description",  "description", False),
    ("ROM",          "rom_name",    True),
]

ROM_COLUMNS = [
    ("Stock ROM ID",  "stock_rom_id"),
    ("Patched ROM ID","patched_rom_id"),
    ("Vehicle",       "name"),
    ("Arch",          "arch"),
    ("MCU",           "mcu"),
    ("Flash",         "flash_kb"),
    ("SHA-256",       "sha256_short"),
]

SELECT_INDICES = [i for i, (_, _, sel) in enumerate(PATCH_COLUMNS) if sel]


def load_manifest() -> dict:
    path = pathlib.Path("manifest.toml")
    if not path.exists():
        sys.exit("manifest.toml not found — run from repo root")
    return tomllib.loads(path.read_text())


def build_rom_rows(roms: list[dict]) -> str:
    lines = []
    for r in roms:
        cells = "".join(f"<td>{html.escape(str(r[k]))}</td>" for _, k in ROM_COLUMNS)
        lines.append(f"<tr>{cells}</tr>")
    return "\n".join(lines)


def build_patch_rows(patches: list[dict]) -> str:
    lines = []
    for p in patches:
        cat_label = CATEGORY_LABELS.get(p["category"], p["category"])
        cells = [
            f"<td><strong>{html.escape(p['name'])}</strong></td>",
            f'<td><span class="badge cat-{html.escape(p["category"])}">{html.escape(cat_label)}</span></td>',
            f"<td>{html.escape(p['description'])}</td>",
            f"<td>{html.escape(p['rom_name'])}</td>",
        ]
        lines.append(f"<tr>{''.join(cells)}</tr>")
    return "\n".join(lines)


PAGE = """\
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>MMC Patches</title>
  <link rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
  <link rel="stylesheet"
        href="https://cdn.datatables.net/2.1.8/css/dataTables.bootstrap5.min.css">
  <style>
    body {{ font-size: .875rem; background: #f5f5f5; }}
    .navbar {{ background: #1a1a2e !important; }}
    .navbar-brand {{ font-family: monospace; letter-spacing: .05em; }}
    .stat {{ font-size: .8rem; color: #adb5bd; }}

    #search-wrap {{ max-width: 320px; }}

    .table-wrap {{ overflow-x: auto; background: #fff;
                   border-radius: .375rem; box-shadow: 0 1px 4px rgba(0,0,0,.08); }}
    table.dataTable {{ border-collapse: collapse !important; }}
    table.dataTable thead th {{ white-space: nowrap; background: #212529;
                                 color: #f8f9fa; border-color: #343a40; }}
    table.dataTable thead th:hover {{ background: #343a40; }}
    table.dataTable tfoot th {{ padding: 4px 6px; background: #f1f3f5; }}
    table.dataTable tfoot select {{
      width: 100%; padding: 2px 4px; font-size: .75rem;
      border: 1px solid #ced4da; border-radius: .25rem; background: #fff;
    }}
    td, th {{ vertical-align: middle !important; }}
    td:last-child {{ white-space: nowrap; }}

    .badge {{ font-size: .72rem; font-weight: 500; }}
    .cat-engine         {{ background: #0d6efd; color: #fff; }}
    .cat-boost          {{ background: #fd7e14; color: #fff; }}
    .cat-rev-limit      {{ background: #dc3545; color: #fff; }}
    .cat-knock          {{ background: #ffc107; color: #212529; }}
    .cat-multimap       {{ background: #6610f2; color: #fff; }}
    .cat-qol            {{ background: #198754; color: #fff; }}
    .cat-obd            {{ background: #0dcaf0; color: #212529; }}
    .cat-dash           {{ background: #6c757d; color: #fff; }}
    .cat-infrastructure {{ background: #212529; color: #adb5bd; }}

    .rom-table td {{ white-space: nowrap; }}
    .hash-short {{ font-family: monospace; font-size: .8rem; color: #6c757d; }}

    .dataTables_info, .dataTables_length, .dataTables_paginate {{ font-size: .8rem; }}
    div.dataTables_wrapper {{ padding: .5rem 0; }}
    section h2 {{ font-size: 1rem; font-weight: 600; margin-bottom: .5rem; }}
  </style>
</head>
<body>

<nav class="navbar navbar-dark mb-3">
  <div class="container-fluid">
    <span class="navbar-brand">mmc-patches</span>
    <span class="stat">{rom_count} ROM target{rom_plural} &mdash; {patch_count} patches &mdash; M32R ECU code injection</span>
  </div>
</nav>

<div class="container-fluid">

  <section class="mb-4">
    <h2>Supported ROMs</h2>
    <div class="table-wrap">
      <table class="table table-sm table-striped rom-table mb-0">
        <thead>
          <tr>
{rom_header}
          </tr>
        </thead>
        <tbody>
{rom_rows}
        </tbody>
      </table>
    </div>
    <p class="text-muted mt-1" style="font-size:.78rem">
      The patch rewrites the ROM ID field so EcuFlash loads the patched XML definition
      only against the patched ROM, never against a stock ROM.
    </p>
  </section>

  <section>
    <h2>Patches</h2>
    <div class="row mb-2 align-items-center g-2">
      <div class="col-auto" id="search-wrap">
        <input id="q" type="search" class="form-control form-control-sm"
               placeholder="&#x1F50D; Search patches&hellip;" autocomplete="off">
      </div>
      <div class="col text-muted" style="font-size:.78rem">
        Category dropdown filters &mdash; click headers to sort
      </div>
    </div>
    <div class="table-wrap">
      <table id="t" class="table table-sm table-striped table-hover w-100">
        <thead>
          <tr>
{patch_header}
          </tr>
        </thead>
        <tfoot>
          <tr>
{patch_footer}
          </tr>
        </tfoot>
        <tbody>
{patch_rows}
        </tbody>
      </table>
    </div>
  </section>

</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/2.1.8/js/dataTables.min.js"></script>
<script src="https://cdn.datatables.net/2.1.8/js/dataTables.bootstrap5.min.js"></script>
<script>
const SEL = {select_indices};

function escRx(s) {{
  return s.replace(/[.*+?^${{}}()|[\\]\\\\]/g, '\\\\$&');
}}

$(function() {{
  var dt = $('#t').DataTable({{
    paging:     false,
    order:      [[1, 'asc'], [0, 'asc']],
    language:   {{ search: '', searchPlaceholder: '' }},
    initComplete: function() {{
      var api = this.api();
      SEL.forEach(function(ci) {{
        var col  = api.column(ci);
        var foot = $(col.footer());
        var sel  = $('<select><option value="">All</option></select>')
          .appendTo(foot.empty())
          .on('change', function() {{
            var v = $(this).val();
            col.search(v ? '^' + escRx(v) + '$' : '', true, false).draw();
          }});
        col.data().unique().sort().each(function(d) {{
          var text = $('<div>').html(d).text().trim();
          if (text) sel.append($('<option>', {{ value: d, text: text }}));
        }});
      }});
    }}
  }});

  $('#t_filter').hide();
  $('#q').on('input search', function() {{
    dt.search($(this).val()).draw();
  }});
}});
</script>
</body>
</html>
"""


def main() -> None:
    data = load_manifest()
    roms_raw = data.get("rom", [])
    if not roms_raw:
        sys.exit("No [[rom]] entries found in manifest.toml")

    roms = []
    all_patches = []

    for r in roms_raw:
        rom_entry = {
            "stock_rom_id":  r.get("stock_rom_id_hex", ""),
            "patched_rom_id": r.get("patched_rom_id_hex", ""),
            "name":          r.get("name", ""),
            "arch":          r.get("arch", ""),
            "mcu":           r.get("mcu", ""),
            "flash_kb":      f"{r.get('flash_kb', '')} KB",
            "sha256_short":  r.get("sha256", "")[:16] + "…" if r.get("sha256") else "",
        }
        roms.append(rom_entry)

        for p in r.get("patches", []):
            all_patches.append({
                "name":        p.get("name", p.get("id", "")),
                "category":    p.get("category", ""),
                "description": p.get("description", ""),
                "rom_name":    r.get("stock_rom_id_hex", r.get("id", "")),
            })

    site = pathlib.Path("site")
    site.mkdir(parents=True, exist_ok=True)

    rom_header = "\n".join(
        f"            <th>{html.escape(label)}</th>" for label, _ in ROM_COLUMNS
    )
    patch_header = "\n".join(
        f"            <th>{html.escape(label)}</th>" for label, _, _ in PATCH_COLUMNS
    )
    patch_footer = "\n".join("            <th></th>" for _ in PATCH_COLUMNS)

    (site / "index.html").write_text(
        PAGE.format(
            rom_count=len(roms),
            rom_plural="s" if len(roms) != 1 else "",
            patch_count=len(all_patches),
            rom_header=rom_header,
            rom_rows=build_rom_rows(roms),
            patch_header=patch_header,
            patch_footer=patch_footer,
            patch_rows=build_patch_rows(all_patches),
            select_indices=json.dumps(SELECT_INDICES),
        ),
        encoding="utf-8",
    )

    html_kb = (site / "index.html").stat().st_size // 1024
    print(f"site/index.html  ({len(roms)} ROM(s), {len(all_patches)} patches, {html_kb} KB)")


if __name__ == "__main__":
    main()
