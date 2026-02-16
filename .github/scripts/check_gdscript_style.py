#!/usr/bin/env python3
"""Lint básico de estilo para GDScript sin dependencias externas."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
IGNORED_ROOTS = {"addons", ".godot", ".git"}


def should_ignore(path: Path) -> bool:
    return any(part in IGNORED_ROOTS for part in path.parts)


def list_gd_scripts() -> list[Path]:
    return sorted(
        path for path in ROOT.rglob("*.gd") if not should_ignore(path.relative_to(ROOT))
    )


def main() -> int:
    scripts = list_gd_scripts()
    if not scripts:
        print("ERROR: No se encontraron scripts .gd fuera de addons/. Nada para lint.")
        return 1

    blocking_findings: list[str] = []
    warnings: list[str] = []

    for script in scripts:
        rel = script.relative_to(ROOT)
        lines = script.read_text(encoding="utf-8").splitlines()

        for line_no, line in enumerate(lines, start=1):
            if line.rstrip(" \t") != line:
                blocking_findings.append(f"{rel}:{line_no} tiene whitespace al final de línea.")

            leading = line[: len(line) - len(line.lstrip(" \t"))]
            if " " in leading and "\t" in leading:
                blocking_findings.append(f"{rel}:{line_no} mezcla tabs y espacios en indentación.")

            if len(line) > 140:
                warnings.append(f"{rel}:{line_no} supera 140 caracteres ({len(line)}).")

    if warnings:
        print("Advertencia: hallazgos de estilo no bloqueantes:")
        for warning in warnings[:60]:
            print(f" - {warning}")
        if len(warnings) > 60:
            print(f" - ... y {len(warnings) - 60} advertencias adicionales.")

    if blocking_findings:
        print("Advertencia: se encontraron problemas de estilo (modo informativo):")
        for finding in blocking_findings[:120]:
            print(f" - {finding}")
        if len(blocking_findings) > 120:
            print(f" - ... y {len(blocking_findings) - 120} hallazgos adicionales.")

    print(f"OK: lint básico completado en {len(scripts)} scripts .gd (sin fallo bloqueante).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
