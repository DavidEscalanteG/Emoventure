# Pruebas smoke en GitHub Actions

Este repositorio ejecuta una prueba smoke automática en **GitHub Actions** mediante el flujo:

- `.github/workflows/godot-ci.yml`

## ¿Qué valida?

El job `smoke-test` ejecuta dos validaciones rápidas:

1. **Validación de autoloads globales (`res://src/autoload`)**
   - Script: `.github/scripts/check_autoload_usage.py`
   - Revisa que los autoloads declarados en `project.godot` y ubicados en `res://src/autoload/` existan con el **mismo case exacto** (importante en Linux/CI).
   - Revisa que el uso en scripts `.gd` (en `src/` y `jugador/`) no use nombres con mayúsculas/minúsculas incorrectas para esos autoloads (por ejemplo `logs.` en vez de `Logs.`).

2. **Arranque mínimo de Godot en modo headless**
   - Comando: `godot --headless --quit --path .`
   - Verifica que el proyecto pueda iniciar sin UI en CI, útil para detectar errores de carga temprana.

## Cuándo se ejecuta

Se ejecuta en:

- cada `push`
- cada `pull_request`

## Cómo ejecutarlo localmente

Desde la raíz del proyecto:

```bash
python3 .github/scripts/check_autoload_usage.py
godot --headless --quit --path .
```

> Nota: en local necesitas tener `python3` y `godot` disponibles en PATH.

## Resultado esperado

- Si todo está bien, el script de autoload imprime:
  - `OK: autoloads en res://src/autoload y su uso básico pasaron la validación.`
- Si hay error, lista cada problema y el workflow falla para evitar regresiones.
