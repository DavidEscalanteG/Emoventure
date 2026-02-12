# Convenciones de código (GDScript)

## 1) Idioma oficial
- **Idioma oficial:** español técnico en `snake_case`.
- Se permite **spanglish controlado** solo para términos del glosario permitido (sección 5).
- Identificadores nuevos (señales, variables, funciones, constantes, nodos lógicos) deben priorizar términos en español.

## 2) Formato de clases y archivos
- **Archivos `.gd` y `.tscn`: `snake_case`** (una sola convención para todo el proyecto).
- `class_name` (si se usa) en `PascalCase` por convención de tipo, pero el archivo sigue en `snake_case`.

## 3) Nombres por tipo de identificador
- **Señales:** `snake_case` en español, en pasado o evento claro.
  - Ejemplo: `dialogo_finalizado`, `accion_cinematica_finalizada`.
- **Variables:** `snake_case` en español, descriptivas.
  - Ejemplo: `direccion_actual`, `linea_actual`, `menu_respuestas`.
- **Funciones públicas:** verbo + contexto en español.
  - Ejemplo: `iniciar_dialogo`, `registrar_actor`, `establecer_animacion`.
- **Funciones privadas:** mismo formato + prefijo `_`.
  - Ejemplo: `_mostrar_linea`, `_gestionar_avance`, `_intentar_establecer_reposo`.
- **Constantes:** `MAYUSCULAS_CON_GUIONES_BAJOS`.
  - Ejemplo: `DIALOGO_ESCENA_1`, `SIGUIENTE_ESCENA`.

## 4) Inventario de identificadores y estado de convención

### Alcance auditado
- Scripts propios (`**/*.gd`) excluyendo `addons/dialogue_manager/**`.
- Refactor aplicado en APIs cruzadas de diálogos, actores y apariencia de jugador.

### Cambios aplicados (antes → ahora)
- `DialogueActors.register_actor` → `DialogueActors.registrar_actor`
- `DialogueActors.set_anim` → `DialogueActors.establecer_animacion`
- `DialogueActors.set_expr` → `DialogueActors.establecer_expresion`
- `DialogueActors.move_and_wait` → `DialogueActors.mover_y_esperar`
- `DialogueActors.move_left/right/up/down` → `mover_izquierda/derecha/arriba/abajo`
- `dialogue_ui.start_dialogue` → `dialogue_ui.iniciar_dialogo`
- `PlayerAppearance.set_direction` → `PlayerAppearance.establecer_direccion`
- `PlayerAppearance.set_estado_movimiento` → `PlayerAppearance.establecer_estado_movimiento`

### Identificadores que rompen convención (pendientes o excepciones)
1. **Callbacks de ciclo de vida y señales de Godot** (excepción técnica):
   - `_ready`, `_process`, `_physics_process`, `_input`, `_unhandled_input`, `_on_*_pressed`, `_on_*_timeout`, `_on_body_entered`.
   - Se mantienen por interoperabilidad con el motor y el editor.
2. **Acciones de input ya configuradas en proyecto** (pendiente controlado):
   - `move_up`, `move_down`, `move_left`, `move_right` (Input Map).
   - Se pueden migrar más adelante con una tarea dedicada y validación de escenas.
3. **Logger global heredado** (pendiente):
   - `set_debug_logs`, `is_debug_enabled`, `log_debug`.

## 5) Glosario permitido (spanglish controlado)
Solo estos términos en inglés están permitidos en identificadores nuevos:
- `preview`
- `ui`
- `dialogue`
- `input`
- `debug`
- `log`
- `idle`
- `walk`

Cualquier otro anglicismo debe evitarse o registrarse primero en este glosario.