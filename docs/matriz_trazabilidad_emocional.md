# Matriz de trazabilidad emocional

Esta matriz conecta cada misión jugable con su objetivo pedagógico, la mecánica implementada, la dimensión emocional evaluada y las preguntas aplicadas del cuestionario. También funciona como checklist operativo para próximas iteraciones.

## 1) Matriz misión → aprendizaje → evaluación

| Misión | Objetivo pedagógico | Mecánica implementada | Dimensión evaluada | Preguntas aplicadas | Evidencia técnica (scripts/escenas) |
|---|---|---|---|---|---|
| **Misión 1: Recolección de emociones (mapa)** | Identificar emociones básicas en contexto y reconocer señales emocionales del entorno. | Recolección de emociones + evitación de enemigos; la misión finaliza cuando se completa el set de emociones y se abre la UI de cierre para continuar a cuestionario. | **Atención** (misión 1 → `atencion`). | Se aplican las 8 preguntas de **Atención** definidas en `Cuestionarios.PREGUNTAS_POR_DIMENSION["atencion"]`. | `scenes/escena_3/mapa_1/mision_1_recoleccion.gd`, `assets/assets_escena_3/UI/NivelCompletadoUI.tscn`, `src/ui/nivel_completado_ui.gd`, `src/autoload/cuestionarios.gd`, `scenes/cuestionarios/escena_cuestionario.gd`. |
| **Misión 2: Memorias eternas** | Favorecer la diferenciación y etiquetado de emociones al asociar recuerdos con una emoción elegida conscientemente. | Selección/confirmación de emoción en 7 cuadros de memoria; al completar todos los cuadros se habilita puerta de cuestionario. | **Claridad** (misión 2 → `claridad`). | Se aplican las 8 preguntas de **Claridad** definidas en `Cuestionarios.PREGUNTAS_POR_DIMENSION["claridad"]`. | `scenes/escena_9/memorias_eternas_gameplay.gd`, `scenes/escena_9/selector_emocion.gd`, `scenes/escena_9/puerta_cuestionario.gd`, `scenes/escena_9/mision_2_memorias.tscn`, `src/autoload/cuestionarios.gd`, `scenes/cuestionarios/escena_cuestionario.gd`. |
| **Misión 3: Pasillo con hachas** | Entrenar autorregulación bajo presión (persistencia, control conductual y recuperación tras error). | Navegación con obstáculos intermitentes (hachas), control de golpes/vidas, checkpoints y salida condicionada por progreso. | **Reparación** (misión 3 → `reparacion`, configurada). | **Configuradas pero no aplicadas en el flujo actual**: 8 preguntas de **Reparación** existen en `Cuestionarios`, pero la escena actual transiciona a recompensa sin instanciar cuestionario. | `scenes/mision_3_hachas/mision_3_hachas.gd`, `scenes/mision_3_hachas/mision_3_hachas.tscn`, `scenes/recompensa_mision_3/recompensa_mision_3.gd`, `src/autoload/cuestionarios.gd`. |
| **Misión 4: Topos (rescate de mascota)** | Fortalecer el foco atencional y la regulación durante actividad de precisión/tiempo limitado, con retroalimentación de desempeño. | Minijuego tipo whack-a-mole con dificultad dinámica, umbrales de victoria/derrota y entrada a cuestionario tras victoria. | **Reparación** (misión 4 → `reparacion`). | Se aplican las 8 preguntas de **Reparación** definidas en `Cuestionarios.PREGUNTAS_POR_DIMENSION["reparacion"]`. | `scenes/escena_topos/mapa_topos.gd`, `scenes/escena_topos/mapa_topos.tscn`, `src/autoload/cuestionarios.gd`, `scenes/cuestionarios/escena_cuestionario.gd`. |

---

## 2) Banco de preguntas por dimensión (fuente única)

> Todas las preguntas se encuentran centralizadas en `src/autoload/cuestionarios.gd` y se inyectan al `EscenaCuestionario` según `numero_mision_cuestionario`.

### Atención (`atencion`)
1. Presto mucha atención a los sentimientos.
2. Normalmente me preocupo mucho por lo que siento.
3. Normalmente dedico tiempo a pensar en mis emociones.
4. Pienso que merece la pena prestar atención a mis emociones y estado de ánimo.
5. Dejo que mis sentimientos afecten a mis pensamientos.
6. Pienso en mi estado de ánimo constantemente.
7. A menudo pienso en mis sentimientos.
8. Presto mucha atención a cómo me siento.

### Claridad (`claridad`)
1. Tengo claros mis sentimientos.
2. Frecuentemente puedo definir mis sentimientos.
3. Casi siempre sé cómo me siento.
4. Normalmente conozco mis sentimientos sobre las personas.
5. A menudo me doy cuenta de mis sentimientos en diferentes situaciones.
6. Siempre puedo decir cómo me siento.
7. A veces puedo decir cuáles son mis emociones.
8. Puedo llegar a comprender mis sentimientos.

### Reparación (`reparacion`)
1. Aunque a veces me siento triste, suelo tener una visión optimista.
2. Aunque me sienta mal, procuro pensar en cosas agradables.
3. Cuando estoy triste, pienso en todos los placeres de la vida.
4. Intento tener pensamientos positivos aunque me sienta mal.
5. Si doy demasiadas vueltas a las cosas, complicándolas, trato de calmarme.
6. Me esfuerzo por tener un buen estado de ánimo.
7. Tengo mucha energía cuando me siento feliz.
8. Cuando estoy enfadado intento que se me pase.

---

## 3) Métricas mínimas (instrumentación base)

Estas métricas son el mínimo recomendado para considerar una misión/ciclo como medible:

1. **Emociones capturadas**
   - Métrica: `emociones_recolectadas.size()` y/o cumplimiento de set esperado.
   - Fuente actual: `DatosJugador.emociones_recolectadas` + señal `todas_las_emociones_recolectadas`.

2. **Respuestas por dimensión**
   - Métrica: cantidad de respuestas registradas en el cuestionario por dimensión (esperado: 8 por cuestionario completo).
   - Fuente actual: arreglo `preguntas` y avance `indice` en `EscenaCuestionario`.

3. **Puntaje por dimensión**
   - Métrica: acumulado por dimensión (`atencion`, `claridad`, `reparacion`).
   - Fuente actual: `GameManager.puntajes_por_dimension` + `agregar_puntaje(dimension, valor)`.

4. **Puntaje total**
   - Métrica: suma global de puntajes de cuestionarios.
   - Fuente actual: `GameManager.puntaje_total`.

5. **Estado de cierre de misión**
   - Métrica: victoria/derrota + transición efectiva a cuestionario/siguiente escena.
   - Fuente actual: lógicas de finalización en scripts de misión (`_finalizar_mision`, `_continuar`, `_on_pressed`, etc.).

---

## 4) Checklist de iteración de contenido (usar en cada nueva versión)

### Diseño pedagógico
- [ ] Cada misión declara explícitamente objetivo pedagógico observable.
- [ ] El objetivo pedagógico está alineado con una única dimensión principal (o se documenta multidimensión).
- [ ] La narrativa previa y posterior refuerza el objetivo emocional de la misión.

### Implementación jugable
- [ ] La mecánica central de la misión está implementada y finaliza con una condición verificable.
- [ ] La escena de misión referencia correctamente su script de control.
- [ ] Existe evidencia técnica trazable (ruta de `.tscn` + `.gd`) para cada mecánica descrita.

### Evaluación emocional
- [ ] `numero_mision_cuestionario` está configurado y validado para la misión.
- [ ] La misión instancia `EscenaCuestionario` al completar condición de éxito (o se documenta excepción).
- [ ] La dimensión inyectada coincide con `Cuestionarios.DIMENSION_POR_MISION`.
- [ ] Las preguntas usadas provienen de `PREGUNTAS_POR_DIMENSION` sin hardcode duplicado en escena.

### Métricas y resultados
- [ ] Se registran emociones capturadas (cuando aplique).
- [ ] Se registran respuestas por dimensión.
- [ ] Se actualiza puntaje por dimensión en `GameManager`.
- [ ] Se actualiza puntaje total y se puede visualizar en resultados finales.
- [ ] Se valida flujo completo misión → cuestionario → siguiente escena.

### Deuda técnica / gaps actuales detectados
- [ ] Resolver trazabilidad de **Misión 3 (hachas)** para que aplique su cuestionario configurado (`mision=3`, `reparacion`) o documentar su exclusión formal.
- [ ] Unificar el flujo de misiones activas (rama narrativa principal vs misión de topos) en un único mapa de producto.

---

## 5) Uso recomendado de esta matriz

- Tratar esta matriz como **fuente de control de cambios** para diseño instruccional + implementación técnica.
- Al crear una misión nueva, completar primero la fila correspondiente y luego implementar escena/script.
- En revisión QA, no aprobar una misión sin evidencia técnica y métricas mínimas completas.
