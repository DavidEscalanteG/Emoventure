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
- **Registro principal de actores en escenas**: las escenas activas usan `DialogueActors.registro_registrar_actor(...)`.
- **Animación y movimiento en escena/diálogo**: las llamadas activas y comandos `#do/##do` usan API canónica (`animacion_establecer_*`, `movimiento_mover_*`).
- **Fachada y servicios de `DialogueActors`**: wrappers legacy retirados; se mantiene únicamente API canónica.

### 4.2 Estado actual
No hay consumidores legacy detectados en escenas ni en diálogos del proyecto para la migración de `DialogueActors`.

## 5) Estado de migración DialogueActors

Checklist por módulo:
- [x] **`DialogueActors` (fachada + servicios separados)**: separación por responsabilidades implementada y en uso.
- [x] **Servicios**: wrappers deprecados retirados; API canónica en uso.
- [x] **Escenas**: registro de actores, animación y arranque de diálogos alineados a convención vigente.
- [x] **Diálogos**: comandos `#do/##do` normalizados a API canónica.

**Criterio de finalización (DoD) de esta migración:**
1. No existan llamadas en escenas/diálogos a wrappers legacy de `DialogueActors`.
2. Se unifiquen los nombres canónicos de la fachada para registro/animación/movimiento en todo el proyecto.
3. Se retiren wrappers deprecados en fachada y servicios.
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
