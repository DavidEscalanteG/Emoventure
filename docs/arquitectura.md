# Arquitectura: Autoloads (Singletons)

Convención vigente para autoloads en `project.godot`:

| Nombre de singleton | Ruta |
| --- | --- |
| `DatosJugador` | `res://src/autoload/DatosJugador.gd` |
| `GameManager` | `res://src/autoload/GameManager.gd` |
| `DialogueActors` | `res://src/autoload/DialogueActors.gd` |
| `Logs` | `res://src/autoload/Logs.gd` |

## Notas de mantenimiento

- Usar estos nombres directamente en scripts (`DatosJugador`, `Logs`, etc.).
- Evitar alias históricos como `Global` para no duplicar conceptos.
- Si se agrega un nuevo autoload, documentarlo aquí y en `project.godot`.