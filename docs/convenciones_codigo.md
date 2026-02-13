# Convenciones de código (GDScript)

## 0) Alcance de estas convenciones
- **Aplican de forma obligatoria** al código y escenas internas del equipo en:
  - `src/`
  - `scenes/`
  - `jugador/`
  - `dialogos/`
- **No aplican como estilo interno** a `addons/dialogue_manager/`, que se considera una **dependencia externa**.
- No se deben hacer cambios de formato, nombres o tipado dentro de `addons/dialogue_manager/` salvo necesidad técnica excepcional y justificada.

## 1) Idioma oficial
- **Idioma oficial:** español técnico en `snake_case`.
- Se permite **spanglish controlado** solo para términos del glosario permitido (sección 6).
- Identificadores nuevos (señales, variables, funciones, constantes, nodos lógicos) deben priorizar términos en español.
- Esta regla de idioma aplica al alcance interno indicado en la sección 0 (`src/`, `scenes/`, `jugador/`, `dialogos/`).

## 2) Formato de clases y archivos
- **Archivos `.gd` y `.tscn`: `snake_case`** (una sola convención para todo el proyecto).
- `class_name` (si se usa) en `PascalCase` por convención de tipo, pero el archivo sigue en `snake_case`.
- Esta regla aplica al alcance interno indicado en la sección 0.

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

## 3.1) Tipado
- En scripts nuevos o editados dentro del alcance interno (`src/`, `scenes/`, `jugador/`, `dialogos/`) se debe usar tipado explícito cuando sea razonable (`: int`, `: String`, `: Node`, etc.).
- Evitar `Variant` implícito si el tipo es conocido.
- Si una API externa obliga tipos dinámicos, documentar el motivo en comentario breve.

## 3.2) Prefijos y visibilidad
- Métodos y helpers privados deben mantener prefijo `_`.
- No introducir prefijos de estilo heredado ajenos a esta convención para código nuevo.
- Estas reglas de prefijos aplican al alcance interno de la sección 0.

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

## 7) Integración con `dialogue_manager` (sin forks directos)
- Si se requiere adaptar comportamiento del plugin, implementar la adaptación en wrappers/puentes propios bajo `src/ui/dialogos/`.
- Evitar forks y modificaciones directas de `addons/dialogue_manager/`.
- Si excepcionalmente se modifica `addons/`, dejar justificación técnica y plan para volver a wrapper propio.

## 8) Mini checklist de PR (cambios en addons)
- [ ] Verifiqué que **no** hay cambios en `addons/`.
- [ ] Si hay cambios en `addons/`, están justificados explícitamente en la PR (motivo, alcance, riesgo).
- [ ] Confirmé que cualquier adaptación de `dialogue_manager` se resolvió en `src/ui/dialogos/` cuando fue posible.
