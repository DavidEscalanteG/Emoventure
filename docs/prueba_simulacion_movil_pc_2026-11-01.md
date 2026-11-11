# Prueba de simulación móvil en PC — 1 de noviembre de 2026

Primera pasada con cinco hallazgos: un problema de joystick que impide usar ese modo de movimiento, dos problemas en cuestionarios y dos detalles de usabilidad. No se modificó la jugabilidad ni se aplicaron correcciones.

## Condiciones y alcance

- Windows, Godot **4.7.2 stable**, renderer Compatibility/OpenGL, GPU Intel. Se eligió Compatibility para aproximar el renderer configurado para móvil en el proyecto.
- Ventanas de **960 × 540 (16:9)** y **1100 × 495 (20:9)**. El juego conserva su área lógica de 1920 × 1080 y añade bandas laterales en 20:9.
- Copia aislada en `.tmp_godot_mobile_pc/`. Guardados y preferencias separados mediante `APPDATA` dentro de esa copia.
- La única sustitución del comportamiento del juego fue hacer que `MobileControlsSettings.is_mobile_device()` devuelva `true` en la copia. Se añadió un observador para capturas, estado y escenarios de prueba.
- Interacción visual mediante clics y arrastres con la emulación de toques ya configurada. Se complementó con eventos `InputEventScreenTouch` sintéticos para mantener pulsaciones y probar dos índices de dedo.
- Se recorrió manualmente menú → partida nueva → selección → personalización → inicio del diálogo. Después se cargaron directamente escenas para revisar las cuatro misiones y un cuestionario completo. **No es una partida completa de principio a fin.**

Las evidencias están en [pruebas/resultados/simulacion_movil_pc_2026-11-01](../pruebas/resultados/simulacion_movil_pc_2026-11-01/). Los PNG capturan el área renderizada y los JSON conservan posiciones, acciones y estado. [source_hashes.json](../pruebas/resultados/simulacion_movil_pc_2026-11-01/source_hashes.json) verifica que los seis archivos principales investigados coinciden con los originales.

## Hallazgos

### 1. Prioridad alta: el joystick aparece fuera de pantalla

**Reproducción:** seleccionar Joystick en configuración o pausa y entrar a la misión de recolección. Repetido en 16:9 y 20:9; también aparece en la misión de saltos.

**Resultado:** el joystick no se ve ni se puede tocar. Su base está en `x = 1960`, con ancho 220, fuera del viewport lógico que termina en `x = 1920`. En recolección esto impide moverse con el modo elegido. Cambiar a Cruceta permite continuar.

**Origen identificado:** `src/ui/mobile_controls.tscn`, nodo `Joystick`, línea 80. El preset de anclaje coloca el control a la derecha y los offsets positivos lo desplazan fuera del área visible. Deben revisarse los anclajes horizontales y comprobar ambos formatos de pantalla después de corregirlo.

Evidencias: [16:9](../pruebas/resultados/simulacion_movil_pc_2026-11-01/11_joystick_fuera_16_9.png), [coordenadas](../pruebas/resultados/simulacion_movil_pc_2026-11-01/11_joystick_fuera_16_9.json), [20:9](../pruebas/resultados/simulacion_movil_pc_2026-11-01/07_mision1_20_9.png).

### 2. Prioridad media: desaparece la pausa al entrar al cuestionario desde la misión de saltos

**Reproducción verificada:** cargar `minijuego3.tscn` y ejecutar la transición original de `Meta._iniciar_cuestionario()`. La meta se activó por código para comprobar esa transición sin completar el recorrido.

**Resultado:** antes de la transición existe `PauseOverlay`; después, el cuestionario tiene cuatro preguntas y carece de ese nodo. El botón de pausa desaparece. Cargar un cuestionario guardado mediante el menú sí crea la pausa.

**Origen identificado:** `PauseOverlayManager` comprueba si el nodo recién añadido ya es `current_scene` (`src/autoload/pause_overlay_manager.gd:21`). La transición añade el cuestionario al árbol antes de asignarlo como escena actual (`scenes/mision_3_nuevo/meta.gd:47`). Esa secuencia no activa la inyección del overlay. Las otras transiciones manuales al cuestionario merecen la misma comprobación; aquí se confirmó la de misión 3.

Evidencias: [captura de la transición original](../pruebas/resultados/simulacion_movil_pc_2026-11-01/43_transicion_real_sin_pausa.png), [registro de verificación](../pruebas/resultados/simulacion_movil_pc_2026-11-01/transition_visual.log), [script utilizado](../pruebas/resultados/simulacion_movil_pc_2026-11-01/confirmar_transicion.gd).

### 3. Prioridad media: cargar un cuestionario desacomoda el texto y las respuestas

**Reproducción:** responder las tres primeras preguntas de Atención, volver al menú de partidas con el arnés y pulsar Cargar. Probado con la ventana 20:9.

**Resultado:** se recuperan correctamente el índice 3 (cuarta pregunta) y el puntaje local 6. Sin embargo, la pregunta larga queda superpuesta al borde superior del pergamino; el título sube y la última opción queda pegada al borde inferior. El defecto persiste después de esperar y de abrir/cerrar la pausa.

Comparación del mismo contenido: el área de pregunta pasa de altura 200 a 333 y la última respuesta pasa de `y = 925.5` a `y = 992`, terminando en `y = 1085` para un viewport de altura 1080.

**Área a investigar:** el cálculo de fuente y tamaño mínimo durante la carga inicial de una pregunta larga, en `scenes/cuestionarios/escena_cuestionario.gd:109`, y los contenedores de `EscenaCuestionario.tscn`. Esta es una pista de implementación; la causa exacta no se corrigió ni quedó aislada.

Evidencias: [antes de cargar](../pruebas/resultados/simulacion_movil_pc_2026-11-01/28_cuestionario_20_9.png), [después de cargar](../pruebas/resultados/simulacion_movil_pc_2026-11-01/30_cuestionario_recuperado.png), [estado restaurado](../pruebas/resultados/simulacion_movil_pc_2026-11-01/30_cuestionario_recuperado.json).

### 4. Usabilidad: el reintento de los payasos es pequeño para tocarlo

Al terminar el tiempo y perder, el botón «Reintentar misión» mide 117 × 39 unidades lógicas: aproximadamente **54 × 18 píxeles** dentro de la ventana 1100 × 495. El texto del detalle usa fuente 24 en la referencia 1920 × 1080 y resulta pequeño en esta simulación. El reintento respondió al clic, pero conviene ampliar su área táctil y la tipografía.

Evidencias: [resultado de derrota](../pruebas/resultados/simulacion_movil_pc_2026-11-01/21_mision4_derrota_texto.png), [medidas del botón](../pruebas/resultados/simulacion_movil_pc_2026-11-01/21_mision4_derrota_texto.json). Nodo en `scenes/mision_4_payasos/mapa_topos.tscn:192`.

### 5. Usabilidad: tocar «Hombre» o «Mujer» no selecciona al personaje

Los toques sobre el centro del texto no avanzan; tocar la figura sí funciona. El texto queda mayormente fuera del rectángulo de su botón padre. Por ejemplo, el botón Mujer abarca `y = 525…825` y su etiqueta `y = 818…930`.

Conviene incluir el texto dentro del área que acepta la selección. Evidencia: [captura y rectángulos](../pruebas/resultados/simulacion_movil_pc_2026-11-01/04_seleccion_nombre_no_responde.json). Nodos en `scenes/intro_seleccion_genero/intro_seleccion_genero.tscn:99` y `:113`.

## Comprobaciones que funcionaron

| Área | Resultado observado | Evidencia |
|---|---|---|
| Menús y configuración | Se puede iniciar, crear partida y elegir Cruceta/Joystick; la preferencia persistió al reiniciar. | `01`, `02`, `25` |
| Selección y personalización | Selección al tocar la figura, cambio de peinado, rechazo del nombre vacío y avance con nombre válido. | Recorrido visual; `04`, `05` en la copia temporal |
| Diálogo inicial | Un toque completa el texto y los siguientes permiten avanzar. | Recorrido visual |
| Pausa | Abre y reanuda en introducción y recolección; también en cuestionario cargado desde guardado. | `03`, `31` |
| Cruceta | Pulsación mantenida mueve al personaje hacia la izquierda: `x = 1089 → 979`, velocidad `−300`. | `37` |
| Dos contactos sintéticos | Activa izquierda/arriba; liberar uno conserva arriba y liberar ambos deja las acciones vacías. | `38`, `39`, `40` |
| Memorias | Se abrió un recuerdo, se eligió y confirmó una emoción: contador `0/7 → 1/7`. Cancelar un segundo selector conservó `1/7`. | `14` y recorrido visual |
| Saltos | Un toque sintético dentro de la ventana inicia el salto; se registró velocidad vertical `−186.67`. Las muertes reinician el nivel. | `41`, `42`; registros |
| Payasos | Los golpes suman puntos; tocar fuera de los objetivos no sumó. El tiempo termina en derrota y Reintentar reinicia el marcador. | `19`, `21` y recorrido visual |
| Cuestionario | Las ocho respuestas permitieron finalizar. Tras tres respuestas, cargar recuperó pregunta y puntaje, con el defecto visual descrito. | `27`, `30`, `32` |

Los identificadores de la última columna corresponden al prefijo de los archivos de evidencia. La [corrida final](../pruebas/resultados/simulacion_movil_pc_2026-11-01/run_final.log) y la verificación de la transición no registraron errores de scripts del juego. Se descartaron incidencias de preparación de la copia y del recolector de datos; no se contaron como fallos del juego.

## Pendiente de validar

No se completaron todos los mapas, los siete recuerdos, la victoria de los payasos ni la historia y el resultado final. Tampoco se evaluaron el teclado virtual de Android/iOS, multitáctil físico, audio percibido, rendimiento en teléfono, batería, calentamiento, interrupciones del sistema o zonas seguras de pantalla. La simulación en Windows no permite dar por aprobados esos puntos.

Se cerraron las ejecuciones de prueba. Las partidas reales y los archivos originales del juego no se modificaron.
