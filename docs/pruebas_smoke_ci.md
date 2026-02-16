# Pruebas smoke en GitHub Actions

Este repositorio ejecuta pruebas smoke automáticas en **GitHub Actions** mediante el flujo:

- `.github/workflows/godot-ci.yml`

## ¿Qué valida?

El job `smoke-test` ejecuta validaciones rápidas para detectar regresiones tempranas:

1. **Validación de autoloads globales (`res://src/autoload`)**
   - Script: `.github/scripts/check_autoload_usage.py`
   - Revisa que los autoloads declarados en `project.godot` y ubicados en `res://src/autoload/` existan con el **mismo case exacto** (importante en Linux/CI).
   - Revisa que el uso en scripts `.gd` (en `src/` y `jugador/`) no use nombres con mayúsculas/minúsculas incorrectas para esos autoloads (por ejemplo `logs.` en vez de `Logs.`).

2. **Validación de sintaxis GDScript (excluyendo `addons/`)**
   - Script: `.github/scripts/check_gdscript_syntax.py`
   - Busca todos los scripts `.gd` del repositorio excepto los que estén dentro de `addons/`, `.godot/` y `.git/`.
   - Ejecuta `godot --headless --check-only --script <archivo>` por cada script para detectar errores de sintaxis tempranamente.
   - Ignora errores conocidos de dependencias de proyecto (autoloads/globales, UIDs y recursos externos) para evitar falsos positivos al revisar scripts individualmente.

3. **Detección de escenas con rutas inválidas o faltantes**
   - Script: `.github/scripts/check_scene_resources.py`
   - Recorre archivos `.tscn` y `.tres` para validar que cada `ext_resource path="res://..."` exista en el repositorio.
   - Valida también el **case exacto** de las rutas para prevenir fallos que solo aparecen en CI/Linux.

4. **Verificación de señales y métodos enlazados en escenas**
   - Script: `.github/scripts/check_scene_connections.py`
   - Recorre conexiones `[connection ...]` en escenas `.tscn`.
   - Valida que los nodos `from` y `to` existan dentro de la escena.
   - Si el nodo de destino tiene script adjunto por `ExtResource`, verifica que el método declarado en `method="..."` exista en ese script.

5. **Lint básico de estilo para GDScript**
   - Script: `.github/scripts/check_gdscript_style.py`
   - Lint liviano sin dependencias externas para detectar:
     - whitespace al final de línea,
     - mezcla de tabs y espacios en indentación.
   - También reporta como advertencia líneas demasiado largas (>140 caracteres).

6. **Escaneo de assets no utilizados (reporte informativo)**
   - Script: `.github/scripts/check_unused_assets.py`
   - Busca archivos en `assets/` que no aparezcan referenciados por rutas `res://...` en archivos de texto del proyecto.
   - Es un reporte **no bloqueante** para visibilidad de deuda técnica y optimización de tamaño/carga.

7. **Arranque mínimo de Godot en modo headless**
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
python3 .github/scripts/check_scene_resources.py
python3 .github/scripts/check_scene_connections.py
python3 .github/scripts/check_gdscript_style.py
python3 .github/scripts/check_unused_assets.py
godot --headless --quit --path .
```

> Nota: en local necesitas tener `python3` y `godot` disponibles en PATH.

## Resultado esperado

- Si todo está bien, cada script bloqueante imprime un `OK:` con resumen de archivos revisados.
- `check_unused_assets.py` reporta `OK` si no detecta assets huérfanos o `WARNING` con listado de candidatos.
- Si hay advertencias por dependencias externas/autoloads en sintaxis o por conexiones sin script detectable, se reportan como aviso.
- Si hay error en validaciones bloqueantes, se listan los problemas y el workflow falla para evitar regresiones.

## Sugerencias de futuras pruebas de CI

1. **Validación de traducciones y llaves de localización**
   - Verificar que las claves usadas en código/escenas existan en los archivos de traducción y no haya llaves huérfanas.

2. **Control de tamaño de build y assets críticos**
   - Agregar alertas por crecimiento abrupto del tamaño de `assets/` o de recursos individuales grandes.

3. **Pruebas smoke por escenas clave (headless/scripted)**
   - Automatizar la carga secuencial de escenas principales (`menu`, `personalización`, transiciones) para detectar errores de inicialización específicos por escena.

4. **Chequeo de consistencia de UIDs y recursos importados**
   - Detectar UIDs duplicados o recursos `.import` desincronizados frente a su archivo fuente.
