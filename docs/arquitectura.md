# Arquitectura: Autoloads (Singletons)

Convención vigente para autoloads en `project.godot`:

| Nombre de singleton | Ruta | Responsabilidad |
| --- | --- | --- |
| `DatosJugador` | `res://src/autoload/datos_jugador.gd` | Estado persistente del jugador y progreso global. |
| `GameManager` | `res://src/autoload/game_manager.gd` | Flujo global del juego y transición de estados de alto nivel. |
| `AudioManager` | `res://src/autoload/audio_manager.gd` | Configuración de buses, volumenes persistentes (`Master`, `Musica`, `SFX`, `Voz`) y reproducción de SFX/UI. |
| `MusicManager` | `res://src/autoload/music_manager.gd` | Único punto de verdad para música de fondo y ambientes (pistas por escena, por clave y por ambiente). |
| `DialogueActors` | `res://src/autoload/dialogue_actors.gd` | Registro/gestión de actores de diálogo. |
| `Logs` | `res://src/autoload/logs.gd` | Canal centralizado de logs del juego. |
| `Cuestionarios` | `res://src/autoload/cuestionarios.gd` | Datos y utilidades globales de cuestionarios. |

## Decisión de audio

- `MusicManager` concentra toda la lógica de BGM/ambientes:
  - selección automática por escena,
  - reproducción por clave (`reproducir_clave`),
  - reproducción por ambiente de diálogo (`reproducir_dialogo_por_ambiente`),
  - reproducción directa por ruta (`reproducir_desde_ruta`) para casos puntuales como previews.
- `AudioManager` **no** decide música por escena ni mantiene reproductor de BGM; solo administra buses/volúmenes y SFX/UI.
- El bus `Musica` se mantiene en `AudioManager` (persistencia de volumen), y `MusicManager` reproduce sobre ese bus para respetar la configuración del usuario.

## Notas de mantenimiento

- Usar estos nombres directamente en scripts (`DatosJugador`, `MusicManager`, etc.).
- Evitar alias históricos como `Global` para no duplicar conceptos.
- Si se agrega un nuevo autoload, documentarlo aquí y en `project.godot`.

## Dependencias externas y adaptaciones

- `addons/dialogue_manager/` se considera dependencia externa del proyecto.
- No aplicar refactors de estilo interno dentro de `addons/dialogue_manager/`.
- Si se necesita adaptar su comportamiento, priorizar wrappers propios en `src/ui/dialogos/`.
