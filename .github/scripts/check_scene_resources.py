#!/usr/bin/env python3
"""Valida que los ext_resource de escenas/recursos apunten a rutas existentes con case exacto."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

EXT_RESOURCE_PATH_RE = re.compile(r'^\[ext_resource\s+.*path="(?P<path>res://[^\"]+)".*\]$')


IGNORED_ROOTS = {".git", ".godot"}


def should_ignore(path: Path) -> bool:
    return any(part in IGNORED_ROOTS for part in path.parts)


def exists_with_exact_case(relative_path: Path) -> bool:
    current = ROOT
    for part in relative_path.parts:
        if not current.is_dir():
            return False
        entries = {entry.name for entry in current.iterdir()}
        if part not in entries:
            return False
        current = current / part
    return current.exists()


def list_scene_like_files() -> list[Path]:
    files: list[Path] = []
    for ext in ("*.tscn", "*.tres"):
        for path in ROOT.rglob(ext):
            rel = path.relative_to(ROOT)
            if should_ignore(rel):
                continue
            files.append(path)
    return sorted(files)


def main() -> int:
    files = list_scene_like_files()
    if not files:
        print("ERROR: No se encontraron archivos .tscn/.tres para validar.")
        return 1

    errors: list[str] = []
    checked_references = 0

    for file_path in files:
        rel = file_path.relative_to(ROOT)
        for line_no, raw_line in enumerate(file_path.read_text(encoding="utf-8").splitlines(), start=1):
            line = raw_line.strip()
            match = EXT_RESOURCE_PATH_RE.match(line)
            if not match:
                continue

            checked_references += 1
            res_path = match.group("path")
            repo_rel = Path(res_path.replace("res://", "", 1))
            if not exists_with_exact_case(repo_rel):
                errors.append(
                    f"{rel}:{line_no} ext_resource apunta a '{res_path}', pero la ruta no existe con ese case exacto."
                )

    if errors:
        print("Se encontraron rutas de recursos inválidas en escenas/recursos:")
        for err in errors:
            print(f" - {err}")
        return 1

    print(
        "OK: "
        f"{len(files)} archivos .tscn/.tres revisados y {checked_references} ext_resource válidos con case exacto."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
