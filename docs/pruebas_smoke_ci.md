# Pruebas smoke en GitHub Actions

Este repositorio ejecuta una prueba smoke automática en **GitHub Actions** mediante el flujo:

- `.github/workflows/godot-ci.yml`

## ¿Qué valida?

El job `smoke-test` ejecuta tres validaciones rápidas:

1. **Validación de autoloads globales (`res://src/autoload`)**
   - Script: `.github/scripts/check_autoload_usage.py`
   - Revisa que los autoloads declarados en `project.godot` y ubicados en `res://src/autoload/` existan con el **mismo case exacto** (importante en Linux/CI).
   - Revisa que el uso en scripts `.gd` (en `src/` y `jugador/`) no use nombres con mayúsculas/minúsculas incorrectas para esos autoloads (por ejemplo `logs.` en vez de `Logs.`).

2. **Validación de sintaxis GDScript (excluyendo `addons/`)**
   - Script: `.github/scripts/check_gdscript_syntax.py`
   - Busca todos los scripts `.gd` del repositorio excepto los que estén dentro de `addons/`, `.godot/` y `.git/`.
   - Ejecuta `godot --headless --check-only --script <archivo>` por cada script para detectar errores de sintaxis tempranamente.
   - Ignora errores conocidos de dependencias de proyecto (autoloads/globales, UIDs y recursos externos) para evitar falsos positivos al revisar scripts individualmente.

3. **Arranque mínimo de Godot en modo headless**
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
python3 .github/scripts/check_gdscript_syntax.py
godot --headless --quit --path .
```

> Nota: en local necesitas tener `python3` y `godot` disponibles en PATH.

## Resultado esperado

- Si todo está bien, el script de autoload imprime:
  - `OK: autoloads en res://src/autoload y su uso básico pasaron la validación.`
- Si todo está bien, el script de sintaxis imprime un resumen similar a:
  - `OK: <N> scripts .gd revisados (excluyendo addons/) sin errores de sintaxis bloqueantes.`
- Si hay advertencias por dependencias externas/autoloads, se reportan como aviso sin tumbar el job, incluyendo detalles de las líneas ignoradas por script.
- Si hay error, se lista cada problema y el workflow falla para evitar regresiones.

## Sugerencias de futuras pruebas de CI

1. **Detección de escenas con rutas inválidas o faltantes**
   - Añadir un script que recorra `.tscn`/`.tres` y confirme que los `ext_resource` apunten a archivos existentes con el case correcto.

2. **Verificación de señales y métodos enlazados en escenas**
   - Detectar conexiones a métodos inexistentes para prevenir fallos al abrir o ejecutar escenas.

3. **Escaneo de assets no utilizados (opcional)**
   - Reportar recursos grandes no referenciados para reducir tamaño del repositorio y tiempos de carga.

4. **Lint de estilo para GDScript**
   - Incorporar `gdlint` (o equivalente) con reglas mínimas para mantener consistencia de estilo y detectar problemas potenciales de mantenibilidad.
