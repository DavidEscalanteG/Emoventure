#!/usr/bin/env python3
"""Valida sintaxis de scripts GDScript (excluyendo addons)."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Revisa la sintaxis de scripts .gd del proyecto, excluyendo addons/."
    )
    parser.add_argument(
        "--godot-bin",
        default="godot",
        help="Binario de Godot a ejecutar (por defecto: godot).",
    )
    parser.add_argument(
        "--max-errors",
        type=int,
        default=30,
        help="Máximo de errores a mostrar antes de detener la revisión (por defecto: 30).",
    )
    return parser.parse_args()


def should_ignore(path: Path) -> bool:
    ignored_roots = {
        "addons",
        ".godot",
        ".git",
    }
    return any(part in ignored_roots for part in path.parts)


def list_gd_scripts() -> list[Path]:
    return sorted(
        path for path in ROOT.rglob("*.gd") if not should_ignore(path.relative_to(ROOT))
    )


def check_script(godot_bin: str, script_path: Path) -> tuple[bool, str]:
    rel_path = script_path.relative_to(ROOT)
    cmd = [
        godot_bin,
        "--headless",
        "--path",
        str(ROOT),
        "--check-only",
        "--script",
        str(rel_path),
    ]

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    return result.returncode == 0, result.stdout.strip()


def main() -> int:
    args = parse_args()

    scripts = list_gd_scripts()
    if not scripts:
        print("ERROR: No se encontraron scripts .gd fuera de addons/. Nada para validar.")
        return 1

    errors: list[str] = []

    for script in scripts:
        ok, output = check_script(args.godot_bin, script)
        if ok:
            continue

        rel = script.relative_to(ROOT)
        message = f"\n[{rel}]\n{output or 'Sin salida del comando.'}"
        errors.append(message)

        if len(errors) >= args.max_errors:
            errors.append(
                f"\nSe alcanzó el límite de {args.max_errors} errores. Deteniendo revisión tempranamente."
            )
            break

    if errors:
        print("Se encontraron errores de sintaxis en scripts GDScript:")
        for entry in errors:
            print(entry)
        return 1

    print(f"OK: {len(scripts)} scripts .gd revisados (excluyendo addons/) sin errores de sintaxis.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
