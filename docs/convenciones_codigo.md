# Convenciones de código (GDScript)

## 1) Idioma oficial
- **Idioma oficial:** español técnico en `snake_case`.
- Se permite **spanglish controlado** solo para términos del glosario permitido (sección 6).
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

## 4) Estado real de migración (auditado)

### 4.1 Migrado completamente
- **Entrada a diálogos desde escenas (`dialogue_ui`)**: las escenas activas usan `dialogue_ui.iniciar_dialogo(...)`.
- **Registro principal de actores en escenas**: las escenas activas usan `DialogueActors.registro_registrar_actor(...)` en lugar de `register_actor(...)`.
- **Servicios internos de `DialogueActors`**: existen servicios separados por módulo (`Registry`, `Animation`, `Movement`) y la fachada principal ya delega en estos servicios.

### 4.2 En transición (con wrappers legacy)
- **Autoload `dialogue_actors.gd`** conserva API legacy de compatibilidad temporal (retiro objetivo 2026-06), incluyendo wrappers como:
  - Registro: `register_actor`, `registrar_actor`, `unregister_actor`, `desregistrar_actor`.
  - Animación: `set_expr`, `establecer_expresion`, `set_anim`, `establecer_animacion`, `play_anim_and_wait`.
  - Movimiento: `move_and_wait`, `mover_derecha`, `mover_izquierda`, `mover_y_esperar`.
- **Servicios (`DialogueActorRegistryService`, `DialogueActorAnimationService`, `DialogueActorMovementService`)** también mantienen wrappers deprecados (`register_actor`, `unregister_actor`, `set_expr`, `set_anim`, `move_and_wait`) para no romper llamadas antiguas.

### 4.3 Scripts/diálogos pendientes por migrar
Pendientes detectados que aún dependen de API legacy o nombres transicionales:
- **Diálogos con comandos legacy de animación/expresión**:
  - `dialogos/escena_1.dialogue` (`DialogueActors.establecer_expresion(...)`).
  - `dialogos/escena_2.dialogue` (`DialogueActors.establecer_expresion(...)`, incluye líneas desactivadas con `##do`).
  - `dialogos/escena_5.dialogue` (`DialogueActors.establecer_expresion(...)`).
  - `dialogos/escena_8.dialogue` (`DialogueActors.establecer_animacion(...)`).
- **Script de escena con nombre transicional/no canónico**:
  - `scenes/escena_8/escena_8.gd` usa `DialogueActors.animacion_set_animacion(...)`; debe alinearse al nombre canónico vigente en la fachada.

## 5) Estado de migración DialogueActors

Checklist por módulo:
- [x] **`DialogueActors` (fachada + servicios separados)**: separación por responsabilidades implementada y en uso.
- [ ] **Servicios (en transición)**: API canónica migrada, pero con wrappers deprecados aún presentes para compatibilidad.
- [ ] **Escenas (en transición)**: registro de actores y arranque de diálogos mayormente migrados; queda normalizar llamada de animación en `escena_8.gd`.
- [ ] **Diálogos**: faltan migrar comandos `#do` que todavía llaman wrappers legacy (`establecer_expresion` / `establecer_animacion`).

**Criterio de finalización (DoD) de esta migración:**
1. No existan llamadas en escenas/diálogos a wrappers legacy de `DialogueActors`.
2. Se unifiquen los nombres canónicos de la fachada para registro/animación/movimiento en todo el proyecto.
3. Se retiren wrappers deprecados en fachada y servicios (o queden detrás de una bandera de compatibilidad explícita).
4. Se valide que las escenas de diálogo siguen funcionando sin regresiones tras el retiro de compatibilidad.

## 6) Glosario permitido (spanglish controlado)
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
