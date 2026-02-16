#!/usr/bin/env python3
"""Valida conexiones de señales en escenas .tscn y métodos objetivo en scripts adjuntos."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
IGNORED_ROOTS = {".git", ".godot", "addons"}

EXT_SCRIPT_RE = re.compile(
    r'^\[ext_resource\s+type="Script"\s+.*path="(?P<path>res://[^\"]+)"\s+id="(?P<id>[^\"]+)".*\]$'
)
NODE_RE = re.compile(r'^\[node\s+(?P<attrs>.+)\]$')
CONNECTION_RE = re.compile(r'^\[connection\s+(?P<attrs>.+)\]$')
ATTR_RE = re.compile(r'(\w+)="([^\"]*)"')
SCRIPT_REF_RE = re.compile(r'^script\s*=\s*ExtResource\("(?P<id>[^\"]+)"\)')
FUNC_RE = re.compile(r'^\s*func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(')


def should_ignore(path: Path) -> bool:
    return any(part in IGNORED_ROOTS for part in path.parts)


def list_scene_files() -> list[Path]:
    return sorted(
        path for path in ROOT.rglob("*.tscn") if not should_ignore(path.relative_to(ROOT))
    )


def parse_attrs(attr_text: str) -> dict[str, str]:
    return {key: value for key, value in ATTR_RE.findall(attr_text)}


def build_node_path(name: str, parent: str | None) -> str:
    if not parent or parent == ".":
        return name
    return f"{parent}/{name}"


def list_script_methods(script_path: Path, cache: dict[Path, set[str]]) -> set[str]:
    if script_path in cache:
        return cache[script_path]

    methods: set[str] = set()
    if script_path.exists():
        for line in script_path.read_text(encoding="utf-8").splitlines():
            match = FUNC_RE.match(line)
            if match:
                methods.add(match.group(1))
    cache[script_path] = methods
    return methods


def main() -> int:
    scenes = list_scene_files()
    if not scenes:
        print("ERROR: No se encontraron escenas .tscn para validar conexiones.")
        return 1

    errors: list[str] = []
    warnings: list[str] = []
    methods_cache: dict[Path, set[str]] = {}
    checked_connections = 0

    for scene in scenes:
        rel_scene = scene.relative_to(ROOT)
        lines = scene.read_text(encoding="utf-8").splitlines()

        ext_scripts: dict[str, Path] = {}
        nodes: set[str] = set()
        root_node_path: str | None = None
        node_script_by_path: dict[str, Path] = {}

        current_node_path: str | None = None

        for line_no, raw_line in enumerate(lines, start=1):
            line = raw_line.strip()

            ext_match = EXT_SCRIPT_RE.match(line)
            if ext_match:
                script_rel = Path(ext_match.group("path").replace("res://", "", 1))
                ext_scripts[ext_match.group("id")] = ROOT / script_rel
                continue

            node_match = NODE_RE.match(line)
            if node_match:
                attrs = parse_attrs(node_match.group("attrs"))
                name = attrs.get("name")
                if name:
                    current_node_path = build_node_path(name, attrs.get("parent"))
                    nodes.add(current_node_path)
                    if attrs.get("parent") is None and root_node_path is None:
                        root_node_path = current_node_path
                        nodes.add(".")
                else:
                    current_node_path = None
                continue

            if current_node_path:
                script_ref = SCRIPT_REF_RE.match(line)
                if script_ref:
                    script_id = script_ref.group("id")
                    script_path = ext_scripts.get(script_id)
                    if script_path:
                        node_script_by_path[current_node_path] = script_path

            connection_match = CONNECTION_RE.match(line)
            if not connection_match:
                continue

            checked_connections += 1
            attrs = parse_attrs(connection_match.group("attrs"))
            source = attrs.get("from")
            target = attrs.get("to")
            method = attrs.get("method")

            if source == "." and root_node_path is not None:
                source = root_node_path

            if target == "." and root_node_path is not None:
                target = root_node_path

            if source and source not in nodes:
                errors.append(
                    f"{rel_scene}:{line_no} conexión desde nodo inexistente: from='{source}'."
                )

            if target and target not in nodes:
                errors.append(
                    f"{rel_scene}:{line_no} conexión hacia nodo inexistente: to='{target}'."
                )
                continue

            if not target or not method:
                continue

            script_path = node_script_by_path.get(target)
            if script_path is None:
                warnings.append(
                    f"{rel_scene}:{line_no} conexión a '{target}.{method}' sin script adjunto detectable; se omite validación de método."
                )
                continue

            if not script_path.exists():
                errors.append(
                    f"{rel_scene}:{line_no} el script de '{target}' no existe: {script_path.relative_to(ROOT)}."
                )
                continue

            methods = list_script_methods(script_path, methods_cache)
            if method not in methods:
                errors.append(
                    f"{rel_scene}:{line_no} método '{method}' no encontrado en {script_path.relative_to(ROOT)} (nodo '{target}')."
                )

    if warnings:
        print("Advertencia: conexiones omitidas por falta de script adjunto detectable:")
        for item in warnings[:40]:
            print(f" - {item}")
        if len(warnings) > 40:
            print(f" - ... y {len(warnings) - 40} advertencias adicionales.")

    if errors:
        print("Se encontraron problemas en conexiones de escenas:")
        for err in errors:
            print(f" - {err}")
        return 1

    print(
        "OK: "
        f"{len(scenes)} escenas .tscn revisadas y {checked_connections} conexiones validadas sin errores bloqueantes."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
