# Documentación de Emoventure (estado actual)

Esta carpeta contiene documentación operativa alineada al estado actual del proyecto Godot.

## Índice recomendado

- `docs/flujo_misiones_emoventure.md`
  Flujo narrativo/jugable vigente, incluyendo cierre en **rejugabilidad**.
- `docs/matriz_transiciones.md`
  Matriz completa de transiciones entre escenas (menú, misiones, cuestionarios, final y rejugabilidad).
- `docs/arquitectura.md`
  Inventario de autoloads y responsabilidades actuales.
- `docs/guia_musical_proyecto.md`
  Mapa musical por claves y escenas consumidoras.
- `docs/matriz_trazabilidad_emocional.md`
  Relación misión ↔ dimensión emocional ↔ evaluación (cuestionarios).
- `docs/convenciones_codigo.md`
  Convenciones de estilo y alcance de aplicación.
- `docs/convencion_nombres_escenas.md`
  Convención semántica de nombres de escenas y mapeo legacy.
- `docs/inventario_rutas_mayusculas.md`
  Auditoría de archivos `.gd`/`.tscn` con mayúsculas en nombre.

## Nota de mantenimiento

Cuando se cambie cualquier transición de escena o autoload, actualizar en el mismo PR:

1. `flujo_misiones_emoventure.md`
2. `matriz_transiciones.md`
3. `arquitectura.md` (si aplica)
