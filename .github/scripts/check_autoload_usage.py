#!/usr/bin/env python3
"""Valida autoloads declarados en project.godot y su uso básico en scripts GDScript."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PROJECT_FILE = ROOT / "project.godot"
SCRIPT_DIRS = [ROOT / "src", ROOT / "jugador"]

AUTOLOAD_LINE = re.compile(r'^(?P<name>\w+)="\*(?P<path>res://[^\"]+)"$')
TOKEN_FOLLOWED_BY_DOT = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\b\s*\.")


def parse_autoloads(project_text: str) -> dict[str, str]:
    autoloads: dict[str, str] = {}
    in_autoload = False

    for raw_line in project_text.splitlines():
        line = raw_line.strip()

        if line.startswith("["):
            in_autoload = line == "[autoload]"
            continue

        if not in_autoload or not line or line.startswith(";"):
            continue

        match = AUTOLOAD_LINE.match(line)
        if match:
            autoloads[match.group("name")] = match.group("path")

    return autoloads


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


def all_script_files() -> list[Path]:
    files: list[Path] = []
    for base in SCRIPT_DIRS:
        if not base.exists():
            continue
        files.extend(sorted(base.rglob("*.gd")))
    return files


def main() -> int:
    if not PROJECT_FILE.exists():
        print("ERROR: No se encontró project.godot en la raíz del repositorio.")
        return 1

    autoloads = parse_autoloads(PROJECT_FILE.read_text(encoding="utf-8"))
    if not autoloads:
        print("ERROR: No se encontraron autoloads declarados en project.godot.")
        return 1

    errors: list[str] = []
    src_autoloads = {
        name: path for name, path in autoloads.items() if path.startswith("res://src/autoload/")
    }

    for name, res_path in src_autoloads.items():
        repo_rel = Path(res_path.replace("res://", "", 1))
        if not exists_with_exact_case(repo_rel):
            errors.append(
                f"Autoload '{name}' apunta a '{res_path}', pero la ruta no existe con ese case exacto."
            )

    canonical_by_lower = {name.lower(): name for name in src_autoloads}

    for gd_file in all_script_files():
        content = gd_file.read_text(encoding="utf-8")
        for token in TOKEN_FOLLOWED_BY_DOT.findall(content):
            canonical = canonical_by_lower.get(token.lower())
            if canonical and token != canonical:
                rel = gd_file.relative_to(ROOT)
                errors.append(
                    f"Uso con case distinto en {rel}: '{token}.' debería ser '{canonical}.'."
                )

    if errors:
        print("Se encontraron problemas en autoloads/globales:")
        for err in errors:
            print(f" - {err}")
        return 1

    print("OK: autoloads en res://src/autoload y su uso básico pasaron la validación.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
