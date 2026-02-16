#!/usr/bin/env python3
"""Reporte no bloqueante de assets no referenciados en archivos de texto del proyecto."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ASSET_ROOT = ROOT / "assets"
IGNORED_ROOTS = {".git", ".godot"}
TEXT_EXTENSIONS = {".gd", ".tscn", ".tres", ".godot", ".import", ".md", ".txt", ".cfg", ".json"}
RES_PATH_RE = re.compile(r"res://[^\s\"')\],]+")


def should_ignore(path: Path) -> bool:
    return any(part in IGNORED_ROOTS for part in path.parts)


def collect_referenced_paths() -> set[Path]:
    referenced: set[Path] = set()

    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        rel = path.relative_to(ROOT)
        if should_ignore(rel):
            continue
        if path.suffix.lower() not in TEXT_EXTENSIONS:
            continue

        text = path.read_text(encoding="utf-8", errors="ignore")
        for match in RES_PATH_RE.findall(text):
            repo_rel = Path(match.replace("res://", "", 1))
            referenced.add(repo_rel)

    return referenced


def collect_asset_files() -> list[Path]:
    if not ASSET_ROOT.exists():
        return []
    assets = [
        path
        for path in ASSET_ROOT.rglob("*")
        if path.is_file() and path.suffix not in {".import", ".uid"}
    ]
    return sorted(assets)


def main() -> int:
    asset_files = collect_asset_files()
    if not asset_files:
        print("WARNING: No se encontraron assets para analizar.")
        return 0

    referenced = collect_referenced_paths()
    unreferenced: list[Path] = []

    for file_path in asset_files:
        rel = file_path.relative_to(ROOT)
        if rel not in referenced:
            unreferenced.append(file_path)

    if not unreferenced:
        print(f"OK: no se detectaron assets huérfanos en {len(asset_files)} archivos de assets.")
        return 0

    unreferenced_sorted = sorted(unreferenced, key=lambda p: p.stat().st_size, reverse=True)
    print(
        "WARNING: posible assets no referenciados detectados "
        f"({len(unreferenced_sorted)} de {len(asset_files)})."
    )
    print("Top 30 por tamaño:")
    for path in unreferenced_sorted[:30]:
        rel = path.relative_to(ROOT)
        size_kb = path.stat().st_size / 1024
        print(f" - {rel} ({size_kb:.1f} KiB)")

    print("Reporte informativo: este check no bloquea CI por ahora.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
