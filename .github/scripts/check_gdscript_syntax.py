#!/usr/bin/env python3
"""Valida sintaxis de scripts GDScript (excluyendo addons)."""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

IGNORABLE_SCRIPT_ERROR_PATTERNS = [
    re.compile(r"could not find type"),
    re.compile(r"identifier not found"),
    re.compile(r"could not resolve external class member"),
    re.compile(r"preload file \"uid://.*\" does not exist"),
    re.compile(r"cannot infer the type of"),
]

IGNORABLE_ENGINE_ERROR_PATTERNS = [
    re.compile(r"^error: unrecognized uid:"),
    re.compile(r"^error: unable to open file:"),
    re.compile(r"^error: failed loading resource:"),
    re.compile(r"^error: cannot open file"),
    re.compile(r"parse error: \[ext_resource\] referenced non-existent resource"),
]



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
    parser.add_argument(
        "--max-warnings",
        type=int,
        default=20,
        help=(
            "Máximo de scripts con advertencias de dependencias externas/autoloads "
            "a mostrar (por defecto: 20)."
        ),
    )
    parser.add_argument(
        "--max-warning-details",
        type=int,
        default=3,
        help=(
            "Máximo de líneas de advertencia ignorada a detallar por script "
            "(por defecto: 3)."
        ),
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


def is_ignorable_script_error(line: str) -> bool:
    line_lower = line.lower()
    return any(pattern.search(line_lower) for pattern in IGNORABLE_SCRIPT_ERROR_PATTERNS)


def is_ignorable_engine_error(line: str) -> bool:
    line_lower = line.lower()
    return any(pattern.search(line_lower) for pattern in IGNORABLE_ENGINE_ERROR_PATTERNS)


def classify_command_output(output: str) -> tuple[list[str], list[str]]:
    fatal: list[str] = []
    ignored: list[str] = []

    for raw_line in output.splitlines():
        line = raw_line.strip()
        if not line:
            continue

        if "SCRIPT ERROR:" in line:
            if is_ignorable_script_error(line):
                ignored.append(line)
            else:
                fatal.append(line)
            continue

        if line.startswith("ERROR:"):
            if is_ignorable_engine_error(line):
                ignored.append(line)
            continue

    return fatal, ignored


def main() -> int:
    args = parse_args()

    if shutil.which(args.godot_bin) is None:
        print(
            f"ERROR: No se encontró el binario de Godot '{args.godot_bin}' en PATH. "
            "Instálalo o usa --godot-bin con una ruta válida."
        )
        return 1

    scripts = list_gd_scripts()
    if not scripts:
        print("ERROR: No se encontraron scripts .gd fuera de addons/. Nada para validar.")
        return 1

    errors: list[str] = []
    warnings: list[str] = []

    for script in scripts:
        ok, output = check_script(args.godot_bin, script)
        if ok:
            continue

        fatal, ignored = classify_command_output(output)
        rel = script.relative_to(ROOT)

        if fatal:
            message = "\n".join([f"[{rel}]", *fatal])
            errors.append(f"\n{message}")

            if len(errors) >= args.max_errors:
                errors.append(
                    f"\nSe alcanzó el límite de {args.max_errors} errores. Deteniendo revisión tempranamente."
                )
                break
            continue

        if ignored:
            unique_ignored = list(dict.fromkeys(ignored))
            details = unique_ignored[: args.max_warning_details]
            warning_message = [
                f"[{rel}] {len(unique_ignored)} advertencias ignoradas por dependencias externas:"
            ]
            warning_message.extend([f"  - {line}" for line in details])
            if len(unique_ignored) > len(details):
                warning_message.append(
                    f"  - ... y {len(unique_ignored) - len(details)} advertencias más en este script."
                )
            warnings.append("\n".join(warning_message))

    if warnings:
        print("Advertencia: se ignoraron errores de dependencias externas/autoloads en algunos scripts:")
        for line in warnings[: args.max_warnings]:
            print(f" - {line}")
        omitted = len(warnings) - min(len(warnings), args.max_warnings)
        if omitted > 0:
            print(f" - ... y {omitted} scripts adicionales con advertencias ignoradas.")

    if errors:
        print("Se encontraron errores de sintaxis en scripts GDScript:")
        for entry in errors:
            print(entry)
        return 1

    print(
        f"OK: {len(scripts)} scripts .gd revisados (excluyendo addons/) sin errores de sintaxis bloqueantes."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
