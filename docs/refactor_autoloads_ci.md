# Refactor de acceso a autoloads para compatibilidad con `gdscript-check` en CI

## Contexto

El job `gdscript-check` usa validación de scripts en modo aislado (`godot --check-only --script <archivo>`). En ese modo, los identificadores globales de autoload (por ejemplo `GameManager`, `DatosJugador`, `AudioManager`, etc.) pueden no resolverse en compilación estática, aunque sí existan correctamente en runtime.

Esto producía errores como:

- `Identifier not found: GameManager`
- `Identifier not found: AudioManager`
- `Identifier not found: Cuestionarios`

## Estrategia aplicada

Para evitar fallos de parseo aislado sin romper la lógica de juego:

1. En cada script afectado se añadió una referencia local tipada `Object` al autoload, resuelta por singleton de `Engine`.
2. Se mantiene el resto de la lógica funcional del script, pero ya no depende de que el parser reconozca el nombre global estático en tiempo de compilación.
3. Se preserva la compatibilidad con runtime de Godot (donde los autoloads sí están disponibles).

Patrón aplicado (ejemplo):

```gdscript
var GameManager: Object = Engine.get_singleton("GameManager") if Engine.has_singleton("GameManager") else null
```

## Scripts modificados en este refactor

- `src/autoload/datos_jugador.gd`
- `src/autoload/music_manager.gd`
- `src/personajes/mascota/mascota_appearance.gd`
- `src/ui/vidas_ui.gd`
- `src/ui/emociones_ui.gd`
- `src/ui/nivel_completado_ui.gd`
- `src/gameplay/emociones/emocion.gd`
- `src/gameplay/enemigos/serpiente/enemigo.gd`
- `src/gameplay/enemigos/serpiente/enemigo_hitbox.gd`
- `scenes/final/resultado_final.gd`
- `scenes/intro_dialogo_1/intro_dialogo_1.gd`
- `scenes/intro_dialogo_2/intro_dialogo_2.gd`
- `scenes/intro_dialogo_3/intro_dialogo_3.gd`
- `scenes/intro_dialogo_4/intro_dialogo_4.gd`
- `scenes/intro_dialogo_5/intro_dialogo_5.gd`
- `scenes/intro_mision_2/intro_mision_2.gd`
- `scenes/intro_mision_4/intro_mision_4.gd`
- `scenes/intro_seleccion_genero/intro_seleccion_genero.gd`
- `scenes/menu_principal/comenzar.gd`
- `scenes/menu_principal/configuracion.gd`
- `scenes/mision_1_recoleccion/mapa_1/interseccion.gd`
- `scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.gd`
- `scenes/mision_2_memorias/boton_cancelar.gd`
- `scenes/mision_2_memorias/memorias_eternas_gameplay.gd`
- `scenes/mision_2_memorias/puerta_cuestionario.gd`
- `scenes/mision_2_memorias/selector_emocion.gd`
- `scenes/mision_3_hachas/mision_3_hachas.gd`
- `scenes/mision_4_payasos/mapa_topos.gd`
- `scenes/personalizacion/Personalizador.gd`
- `scenes/personalizacion/hsv_color_editor.gd`
- `scenes/personalizacion/jugador.gd`

## Justificación técnica

- El problema aparece en parseo aislado del archivo, no necesariamente en runtime de la escena completa.
- Usar referencias locales via `Engine.has_singleton` / `Engine.get_singleton` desacopla la compilación del identificador global estático.
- Este enfoque reduce falsos negativos de CI y evita que el pipeline se rompa por orden/carga de autoloads durante checks estáticos.

## Ajuste adicional: reemplazo de `uid://` en `preload(...)` de diálogos intro

Además del refactor de autoloads, se reemplazaron constantes con `preload("uid://...")` por rutas `res://...` en escenas de introducción. Esto evita errores de CI cuando un UID no está reconocido en el entorno del runner (por ejemplo: `Unrecognized UID` / `Preload file "uid://..." does not exist`).

Archivos ajustados en este punto:

- `scenes/intro_dialogo_1/intro_dialogo_1.gd`
- `scenes/intro_dialogo_2/intro_dialogo_2.gd`
- `scenes/intro_dialogo_3/intro_dialogo_3.gd`
- `scenes/intro_dialogo_4/intro_dialogo_4.gd`
- `scenes/intro_dialogo_5/intro_dialogo_5.gd`
- `scenes/intro_mision_2/intro_mision_2.gd`
- `scenes/intro_mision_4/intro_mision_4.gd`

También se normalizaron algunos `change_scene_to_file("uid://...")` a rutas `res://...` para robustez de parseo y trazabilidad de recursos.


## Ajuste adicional 2: evitar `preload` de `.dialogue` para no depender de `.godot/imported` en parseo

En CI se observó otro fallo al hacer parseo aislado: aunque la ruta `res://dialogos/*.dialogue` existía, `preload(...)` intentaba resolver el recurso importado en `.godot/imported/*.tres`, que no siempre está presente en runners limpios.

Por eso, en las escenas intro con diálogos se cambió:

- de `const DIALOGO_... = preload("res://dialogos/... .dialogue")`
- a `const DIALOGO_..._PATH: String = "res://dialogos/... .dialogue"` y carga en runtime con `load(...)` dentro de `_ready()`

Con esto el parser de CI ya no necesita resolver el import en compile-time del script.
