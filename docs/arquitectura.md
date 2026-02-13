# Arquitectura: Autoloads (Singletons)

Convención vigente para autoloads en `project.godot`:

| Nombre de singleton | Ruta |
| --- | --- |
| `DatosJugador` | `res://src/autoload/datos_jugador.gd` |
| `GameManager` | `res://src/autoload/game_manager.gd` |
| `DialogueActors` | `res://src/autoload/dialogue_actors.gd` |
| `Logs` | `res://src/autoload/logs.gd` |

## Notas de mantenimiento

- Usar estos nombres directamente en scripts (`DatosJugador`, `Logs`, etc.).
- Evitar alias históricos como `Global` para no duplicar conceptos.
- Si se agrega un nuevo autoload, documentarlo aquí y en `project.godot`.

## Dependencias externas y adaptaciones

- `addons/dialogue_manager/` se considera dependencia externa del proyecto.
- No aplicar refactors de estilo interno dentro de `addons/dialogue_manager/`.
- Si se necesita adaptar su comportamiento, priorizar wrappers propios en `src/ui/dialogos/`.
