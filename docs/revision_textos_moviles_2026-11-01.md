# Revisión y corrección de textos en móvil

Se revisaron las interfaces activas en ventanas horizontales de **854 × 480** y **640 × 360**, conservando la fuente pixelada, las ilustraciones, los pergaminos y la paleta del juego. La revisión anterior de jugabilidad no cubría todos estos textos.

## Cobertura

- 39 escenas completas: menús, configuración, créditos, introducciones, personalización, misiones, recompensas, resultados y rejugabilidad.
- Las 134 líneas y respuestas compiladas de los 14 archivos de diálogo, incluyendo las opciones de las distintas ramas. Se renderizaron individualmente, sin ejecutar sus acciones narrativas.
- Los 28 pasos de los cuatro tutoriales.
- Las 24 preguntas, cargadas individualmente desde cero para comprobar también el defecto de la pregunta larga al restaurar una partida.
- Los 73 mensajes de retroalimentación de memorias.
- Resultados de ambos géneros y distintos puntajes, empates, el mensaje largo de descarga, nombres largos de jugador/mascota y pantallas de victoria/derrota.

La auditoría final registró **634 escenarios** y **2732 muestras de texto**. Las muestras incluyen repeticiones entre escenarios y resoluciones; no son 2732 frases diferentes.

## Cambios aplicados

`MobilePresentation` aplica la presentación móvil después de crear cada escena y también a los textos generados dinámicamente. Utiliza la detección existente de `MobileControlsSettings`.

- Texto de interfaz con fuente de al menos 48 unidades lógicas, ajustada cuando el propio nodo ya tiene escala. A 640 × 360 equivale a 16 píxeles nominales en los elementos sin escala adicional. Los diálogos usan 54 y sus nombres de personaje 48.
- Botones con altura mínima y ancho suficiente para conservar palabras completas. El selector Cruceta/Joystick también amplía la letra de su menú desplegable.
- Diálogos con fondo oscuro más sólido, colores de personaje más claros, botón Continuar y desplazamiento para los párrafos largos. Completar la animación del texto también muestra las respuestas disponibles.
- Personalización, resultados y panel de victoria con desplazamiento. Se conserva el personaje visible mientras se recorre el formulario. Las explicaciones de color, intensidad y brillo aparecen dentro del panel móvil y no dependen de un tooltip de ratón.
- Filas de guardados más anchas, información que puede ocupar varias líneas y acciones más grandes.
- Marcos y contenido ampliados en configuración y en los resultados de los payasos. La pausa se vuelve a colocar después de que la interfaz termine de ajustar sus tamaños.
- Caja de pregunta de altura estable: se desactivó `fit_content`, que hacía crecer el cuestionario al cargar una pregunta larga. En móvil se ajustaron las opciones al ancho de sus pergaminos sin partir sus textos.
- Las etiquetas Hombre/Mujer quedan dentro de los botones de selección.
- Los controles interiores de las zonas desplazables dejan llegar el gesto táctil al contenedor. Se comprobó un arrastre real de eventos de contacto, además de la accesibilidad programática de los botones del final.

La presentación móvil se limita a dispositivos que el proyecto identifica como móviles. El ajuste de altura del cuestionario y la aparición de respuestas al completar un diálogo también corrigen esos comportamientos en escritorio.

## Comparación visual

| Interfaz | Antes | Después |
|---|---|---|
| Diálogo | [Captura](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/antes/dialogo.png) | [Captura](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/despues/dialogo.png) |
| Pregunta larga al cargar | [Captura](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/antes/cuestionario_largo.png) | [Captura](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/despues/cuestionario_largo.png) |
| Tutorial | [Captura](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/antes/tutorial_1.png) | [Captura](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/despues/tutorial_1.png) |
| Personalización | [Captura](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/antes/personalizacion.png) | [Captura](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/despues/personalizacion.png) |
| Configuración | [Captura](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/antes/configuracion.png) | [Captura](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/despues/configuracion.png) |
| Resultados | [Captura](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/antes/resultados.png) | [Captura](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/despues/resultados.png) |

Otras muestras: [nombres largos](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/despues/guardado_largo.png), [mensaje de descarga y botones al final](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/despues/resultados_descarga.png), [retroalimentación larga](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/despues/memoria_larga.png), [resultado de payasos](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/despues/payasos_derrota.png).

El contenido que continúa por debajo del borde de una zona desplazable se considera accesible mediante desplazamiento, no un recorte de su caja. Se comprobó que se puede llegar a Comenzar aventura y a los botones de resultados.

## Validación

Motor utilizado: Godot 4.7.2, con render OpenGL/Compatibility para la auditoría visual y perfiles de usuario separados de las partidas reales.

| Comprobación | Resultado |
|---|---|
| 634 escenarios renderizados a dos resoluciones | Completados |
| Fuente nominal menor a 14 píxeles en las muestras finales | 0 |
| Contenido recortado dentro de su propio Label/RichTextLabel | 0 |
| Cajas de texto fuera de pantalla sin un antecesor desplazable | 0 |
| Suite específica de presentación móvil | 685 comprobaciones, 0 fallos |
| Validador existente de cuestionarios, móvil y escritorio | 24 preguntas aprobadas en cada perfil |
| Suite existente de personalización en escritorio | 517 comprobaciones, 0 fallos |

El umbral de 14 píxeles es un criterio de detección de texto pequeño para esta simulación. El objetivo habitual de los nuevos textos es mayor; ese número no certifica accesibilidad ni comodidad de lectura en un teléfono físico.

La suite móvil comprueba los pergaminos, recortes, solapamientos entre opciones, acceso a botones mediante desplazamiento, conservación de señales y campos, el desplegable y la aparición de respuestas al completar un diálogo. También inyecta pulsación, arrastre y liberación de un contacto en el formulario. Se comprobó visualmente el botón Continuar y el desplazamiento con rueda en la ventana del juego.

Registros: [auditoría final](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/despues/audit.json), [validación móvil](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/validacion.log), [ejecución visual](../pruebas/resultados/auditoria_textos_moviles_2026-11-01/despues.log). Las capturas representativas se conservan junto al informe; las capturas completas de las pasadas están en `.tmp_godot_mobile_pc/full_text_audit_2026-11-01/`.

## Límites

Queda pendiente validar en un teléfono físico la lectura con su tamaño y densidad reales, el teclado virtual y los gestos del sistema. No se certifican aquí orientación vertical, textos del selector de archivos nativo del sistema ni el PDF exportado. Se excluyeron los antiguos prototipos de `mision_3_hachas`, que no forman parte del recorrido actual de la misión de saltos.

Al cargar escenas narrativas aisladamente, las auditorías anterior y final registran advertencias preexistentes sobre `dialogo_calma.mp3` y el actor `fran` en `intro_mision_4`. Se conservan en los registros y no se cuentan como fallos nuevos de presentación. La incidencia de pausa al inyectar una transición artificial sigue fuera de esta revisión. El joystick se corrigió y se verificó con contacto táctil en la revisión de composición del 3 de noviembre; ver `revision_composicion_movil_2026-11-03.md`.
