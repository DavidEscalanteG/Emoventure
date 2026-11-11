# Arquitectura: Autoloads (Singletons)

Estado actual de autoloads definidos en `project.godot`.

| Nombre de singleton | Ruta | Responsabilidad |
| --- | --- | --- |
| `DialogueManager` | `res://addons/dialogue_manager/dialogue_manager.gd` | Runtime del plugin de diálogos (dependencia externa). |
| `DatosJugador` | `res://src/autoload/datos_jugador.gd` | Estado persistente del jugador (género, progreso, emociones recolectadas, etc.). |
| `GameManager` | `res://src/autoload/game_manager.gd` | Puntajes globales, rotación M1, bandera de rejugabilidad y reinicio del estado temporal de M3/M4 al comenzar otro recorrido. |
| `SaveManager` | `res://src/autoload/save_manager.gd` | Slots, apariencia, puntajes y cuestionario pendiente. Nueva partida y carga limpian el estado temporal anterior; los checkpoints de M3 solo duran durante los reintentos del recorrido actual. |
| `AudioManager` | `res://src/autoload/audio_manager.gd` | Buses, volúmenes persistentes y reproducción de SFX/UI. |
| `DialogueActors` | `res://src/autoload/dialogue_actors.gd` | Registro, animación y movimiento de actores de diálogo (fachada canónica). |
| `Logs` | `res://src/autoload/Logs.gd` | Canal centralizado de logs del proyecto. |
| `Cuestionarios` | `res://src/autoload/cuestionarios.gd` | Banco de preguntas y mapeo misión→dimensión emocional. |
| `MusicManager` | `res://src/autoload/music_manager.gd` | Música por escena, por clave y por ambiente narrativo temporal. |

## Decisiones vigentes de audio

- `AudioManager` conserva la configuración de buses (`Master`, `Musica`, `SFX`, `Voz`) y su persistencia.
- `MusicManager` decide tema por escena (`_pistas_por_escena`) y reproduce sobre el bus `Musica`.
- El sistema soporta override temporal para diálogos (`misterio`, `tension`, `calma`, `ternura`) y restaura el tema base al terminar.

## Dependencias externas

- `addons/dialogue_manager/` se trata como dependencia externa.
- No se refactoriza estilo interno de este addon salvo necesidad técnica puntual.
- Integraciones propias del proyecto deben ir en `dialogos/` y `src/ui/dialogos/`.

## Notas de mantenimiento

1. Cualquier nuevo autoload debe registrarse en `project.godot` y actualizar esta tabla.
2. Evitar aliases legacy para singletons (por ejemplo `Global`) para no duplicar estado.
3. Si se modifica flujo global de rejugabilidad o puntajes, documentar junto a `GameManager`.
