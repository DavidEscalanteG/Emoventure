# Validación de Emoventure (Godot 4.5)

Ejecutar desde la raíz del proyecto con Python y el ejecutable de consola de Godot 4.5:

```powershell
python pruebas/validacion/validar_proyecto.py --godot "C:/ruta/Godot_v4.5-stable_win64_console.exe" --smoke
```

`--project` permite indicar otra copia del proyecto. `--logs` permite elegir dónde conservar los registros; por defecto se crea una carpeta temporal. El comando devuelve un código distinto de cero ante errores, advertencias, conflictos de Git, cierres inesperados o pruebas incompletas. No basta con que Godot devuelva código cero: también se revisa su salida.

Para comprobar específicamente el editor de colores de personalización:

```powershell
godot_console --headless --path . --script res://pruebas/validacion/probar_personalizacion.gd
```

Esta prueba verifica carga de colores, independencia entre secciones, actualización del personaje y de los indicadores, límite de brillo, ajuste con teclado, arrastre y recuperación del color al reabrir la escena. Solo modifica la apariencia en memoria; no guarda partidas.

## Cobertura

- Importación y arranque del editor.
- Carga de scripts y recursos propios e instanciación de todas las escenas del proyecto. Los complementos se inicializan en la prueba del editor.
- Movimiento, salto, pausa/reanudación, muerte, colisión con púas y puntos de aparición de la misión 3.
- Las diez puertas se prueban mediante colisiones físicas; la última abre las cuatro preguntas de la misión 3 y configura su recompensa.
- Rejugabilidad: al terminar vuelve al mapa sin repetir el cuestionario.
- Pulsación/liberación de la cruceta y existencia de sus texturas y zonas táctiles.
- Redirección de guardados completados. La prueba que **escribe y carga una partida** solo se habilita cuando `application/config/name` es exactamente `EmoventureValidation`; usar este nombre únicamente en una copia temporal con datos de usuario separados.
- Con `--smoke`, arranque durante 180 pasos de física de las 50 escenas principales. El cuestionario se prueba mediante el flujo de la misión porque requiere preguntas y dimensión; los componentes se comprueban al instanciar recursos y escenas.

Las pruebas de puertas sitúan al jugador junto a cada salida. Comprueban las transiciones, pero no sustituyen una partida completa para evaluar la dificultad de cada recorrido. Los controles táctiles se verifican por código; todavía corresponde probarlos en un dispositivo Android real.

## Correcciones realizadas

Los errores iniciales procedían de conflictos de merge sin resolver en cinco `.import`, `jugador.gd` y `nivel_2.tscn`. Había también una ruta de controles inexistente, una textura de hacha ausente, nodos duplicados, referencias heredadas rotas y una señal duplicada.

La misión 3 mantiene su ruta y UID originales, pero ahora instancia el primer nivel del plataformero. La secuencia es `mision_3_hachas` → `nivel2` … `nivel10` → cuestionario → recompensa existente → misión 4. `nivel_1` sigue disponible para probar el primer nivel directamente. Los prototipos `nivel_2` a `nivel_5` permanecen fuera de la secuencia de la historia.

Se recuperó la textura del hacha del historial; se repararon colisiones, aparición, puertas, detección de trampas y reinicios diferidos. Se mantuvo el ajuste de movimiento del plataformero de la rama incorporada: velocidad 480, salto -760 y gravedad ×1.6. Guardado y música reconocen los subniveles.

También se corrigieron referencias de diálogos iniciales, los nombres de métodos de apariencia, la estructura incompleta de `intro_mision_4`, el temporizador del globo de diálogo y la vida útil de la animación del texto de la parca. La introducción 4 conserva su diálogo provisional; no se inventó contenido narrativo.

Los cambios que ya existían en el menú, tema y tutorial de la misión 1 se conservaron.

## Última ejecución: 21 de septiembre de 2026

Motor: Godot 4.5 stable oficial (`876b29033`), usando un proyecto temporal con perfil `EmoventureValidation`, separado de las partidas reales.

- Editor e importación: sin errores ni advertencias.
- 233 recursos propios cargados; escenas instanciadas sin errores ni advertencias.
- 50 escenas principales ejecutadas; registros sin errores ni advertencias.
- 41 comprobaciones de funcionamiento aprobadas, incluidas las colisiones reales de puertas y púas, controles, guardado y carga.
- Cero marcadores de conflicto y cero `.import` con ruta de origen incorrecta.
- `git diff --check` correcto.
- Revisión visual mediante render de Godot de los niveles 1 y 5.

La revisión de cierre también encontró temporizadores pendientes en intersecciones y fuegos de la misión 1. Se sustituyeron por secuencias ligadas a sus nodos, que se pausan y liberan con el nivel. Se comprobó la aparición, pausa y extinción del fuego, incluyendo la liberación de su intersección.

Los registros de esta ejecución quedaron en las carpetas temporales `emoventure-validation-final` y `emoventure-smoke`. El comando anterior permite repetir las comprobaciones y generar nuevos registros.


## Revisión final: 25 de octubre de 2026

Se preservaron los cambios locales del editor de colores. La revisión añadió:

- Indicación junto a la puerta de memorias al explorar los siete recuerdos. La máscara de clic excluye el margen transparente del PNG.
- Corrección de la muerte en el laberinto: los temporizadores de emoción y congelamiento ya no reactivan a un jugador con cero vidas. La partida finalizada tampoco puede abrir la pantalla de victoria. Se reprodujo el fallo con el código anterior.
- Opciones de cuestionario con fuente de 34, separación entre filas y escala fija al recibir foco, sin áreas superpuestas. Las 24 preguntas mantienen su ajuste de fuente.
- Mensajes de los tutoriales 3 y 4 a 42, navegación a 32, indicador de paso a 26 y omisión a 34, tomando el tutorial 1 como referencia (el tutorial 2 usa mensajes de 36). Se amplió el panel inferior y el botón de omisión.
- PDF A4 vectorial con codificación WinAnsi explícita, ajuste de palabras y saltos de página, tarjetas por dimensión, fecha, puntajes, perfil completo y pie numerado. Mantiene los mensajes y umbrales existentes.
- Material compartido para neutralizar el color de las cuatro piezas coloreables del personaje antes de aplicar las barras HSV, conservando luces, sombras, contornos y transparencia. Los PNG originales se conservan. Los indicadores blancos y etiquetas de las barras existentes se verificaron.
- Eliminación de una referencia de la escena de pruebas a una etiqueta del editor de colores que ya no existe.

Pruebas específicas (Godot 4.7.2 disponible en este equipo):

```powershell
# Perfil temporal dentro del proyecto; no utiliza las partidas reales.
$env:APPDATA = Join-Path (Get-Location) ".tmp_godot_revision"
$env:CODEX_PDF_CAPTURE_DIR = "res://.tmp_godot_revision/pdf"
godot_console --headless --path . --script res://pruebas/validacion/probar_revision_final.gd
godot_console --headless --path . --script res://pruebas/validacion/probar_personalizacion.gd
godot_console --headless --path . res://pruebas/validacion/validar_legibilidad_cuestionarios.tscn
# La prueba de color necesita render real, sin --headless.
godot_console --path . --rendering-method gl_compatibility --position=-3000,-3000 --script res://pruebas/validacion/probar_color_personaje.gd
python pruebas/validacion/validar_pdf_resultados.py .tmp_godot_revision/pdf
```

La validación PDF requiere `pypdf` y `pdfplumber`. El directorio de resultados puede cambiarse con `CODEX_PDF_CAPTURE_DIR`. La prueba guarda seis perfiles de ejemplo y un caso con nombre largo; no exporta información personal real. Las capturas se pueden repetir con `capturar_revision.gd`, pasando la escena y ruta PNG tras `--`; el argumento opcional `puerta` completa las memorias para mostrar la salida.

Se verificaron 368 comprobaciones de revisión final, 20 de color en GPU, los controles de personalización y las 24 preguntas. Los siete PDF pasaron extracción de texto y comprobación de márgenes; se revisaron capturas de cuestionario, ambos tutoriales, memorias, personalización y el PDF renderizado con Poppler. La suite de funcionamiento previa pasó sus comprobaciones; Godot 4.7.2 informa al cerrar algunas suites referencias de audio MP3 pendientes (menú, tutorial o game over), ajenas a los puntos corregidos; no son fallos de las comprobaciones funcionales.


### Personalización: colores iniciales y lectura en teléfono

El cabello inicia en café luminoso (`#bd7a42`), la ropa en naranja vivo (`#ff8b39`) y la piel en el tono medio original (`#d89878`). La piel conserva la paleta dibujada y la ropa parte de brillo completo; el cabello pasa del 35 % inicial al 74 %. Los colores guardados, incluido el blanco elegido deliberadamente, se respetan. Los perfiles sin esos campos usan los nuevos valores iniciales.

La pantalla mantiene el personaje y su mascota a la izquierda y muestra una sola sección de color a la derecha, con pestañas Cabello / Ropa / Piel. Usa la fuente pixelada PlainPixel del juego con espaciado compacto, títulos de barra de 44 y explicaciones permanentes de 38, áreas de barra de 100 y selectores más grandes. Los paneles reutilizan el tile de pergamino de Configuración y los botones reutilizan las hojas azul, verde y amarilla del menú. El icono de inicio también procede de esos botones. Los tiles se amplían con vecino más cercano en un tema propio de la escena para conservar sus bordes sin cambiar otros menús. Se ampliaron el nombre, las flechas de peinado y mascota y el botón Comenzar. El preview no crea controles de movimiento en teléfonos.

`probar_personalizacion.gd` también comprueba los valores iniciales, carga de colores, pestañas por clic, textos y barras dentro de pantalla, y validación del nombre a 1920×1080, 854×480 y 640×360. Para guardar las nueve capturas, ejecutar sin `--headless`:

```powershell
$env:APPDATA = Join-Path (Get-Location) ".tmp_godot_revision"
$env:CODEX_PERSONALIZACION_CAPTURE_DIR = "res://.tmp_godot_revision/capturas/personalizacion"
godot_console --path . --rendering-method gl_compatibility --position=-3000,-3000 --script res://pruebas/validacion/probar_personalizacion.gd
```

Estas son pruebas de ventanas de escritorio a resoluciones reducidas; falta comprobar el teclado virtual y la interacción en un teléfono Android físico.

Resultado de esta revisión: 191 comprobaciones de personalización y 368 de regresión aprobadas; 255 recursos cargados e instanciados sin fallos. Se inspeccionaron las nueve capturas de las tres pestañas a las tres resoluciones.


### Piel predeterminada: paleta de los sprites originales

Se inspeccionaron las tres hojas `char_a_pONE1/2/3_0bas_humn_v00.png`. Su paleta contiene tono medio `#d89878`, luces `#f8d8b8`, sombras `#885848`, contornos `#181818` y detalles claros `#f8f8f8`. Cambiar solo el color inicial no recuperaba esas diferencias porque el material neutro eliminaba los matices de las sombras.

El cuerpo usa ahora un material de piel que ajusta tono, saturación y brillo respecto del tono medio original. Con `COLOR_PIEL_INICIAL` conserva exactamente los colores dibujados; las barras siguen modificando el tono medio, con sombras relativas, saturación cero neutra y transparencia para los efectos. Cabello y ropa mantienen su material anterior. Las partidas existentes conservan los colores elegidos.

Validación de render real (sin `--headless`):

```powershell
$env:APPDATA = Join-Path (Get-Location) ".tmp_godot_revision"
godot_console --path . --rendering-method gl_compatibility --position=-3000,-3000 --script res://pruebas/validacion/probar_piel_original.gd
godot_console --path . --rendering-method mobile --position=-3000,-3000 --script res://pruebas/validacion/probar_piel_original.gd
```

Se compararon los 48 037 píxeles opacos de las tres hojas contra el render original: cero diferencias exactas en RGBA8 tanto con OpenGL como con Vulkan Forward Mobile en este equipo. Se verificaron además colores personalizados, blanco sin tinte original, contornos, transparencia y parpadeo. La prueba de personalización mantiene sus 191 comprobaciones y las nueve capturas. Vulkan Forward Mobile en escritorio no sustituye una prueba en Android físico.

### Personalización: distribución A con panel lateral

Se reúne el nombre, peinado, mascota, pestañas, barras y botón de inicio en un único panel a la derecha. El personaje y su mascota aparecen sobre el suelo del camerino; se elimina el oscurecimiento global y se conserva visible el espejo. El panel usa contenedores y nombres únicos para que los controles y sus referencias se mantengan al cambiar de sección. Las miniaturas proceden de los fotogramas originales y conservan los colores elegidos. El gato sin reposo derecho usa su animación izquierda reflejada, tanto en la escena como en la miniatura.

Las explicaciones de las barras están disponibles en sus ayudas emergentes; las etiquetas Color, Intensidad y Brillo permanecen visibles. Se conserva el límite de brillo, la sincronización global, la validación del nombre y el guardado existente.

La prueba `probar_personalizacion.gd` comprueba además la contención de todos los controles, el espacio libre del camerino, clics en las flechas y en Comenzar con nombre vacío, miniaturas sincronizadas y ciclos completos de las seis mascotas en ambos sentidos. Ejecutar con un APPDATA separado, como en el ejemplo anterior. Las capturas siguen usando `CODEX_PERSONALIZACION_CAPTURE_DIR`.

Resultado: 347 comprobaciones aprobadas con render OpenGL y nueve capturas a 1920×1080, 854×480 y 640×360. Se revisó también una captura con el renderizador Vulkan Forward Mobile configurado por el proyecto. Sin errores de script ni recursos en esas ejecuciones.

### Retrato de cabeza y referencia obsoleta del patio de pruebas

La miniatura separa la cabeza del fotograma corporal siguiendo la mandíbula, sin hombros ni brazos, y conserva el cabello completo como otra capa. Ambas capas comparten centro y una escala entera que se adapta al espacio disponible, incluidos los peinados largos y la opción sin cabello. Los cambios de piel y cabello siguen reflejándose en el retrato.

`probar_personalizacion.gd` recorre los 35 índices de peinado, comprueba centrado, contención y ausencia de hombros, y mantiene las verificaciones de interacción a tres resoluciones. Resultado con las nueve capturas: 526 comprobaciones, cero fallos y sin errores de script. También se inspeccionó el retrato con Vulkan Forward Mobile.

Al abrir el editor se reproducía `Invalid unicode codepoint (f3)` junto al aviso de un nodo inexistente: `Selección de personaje/CanvasLayer/PanelContainer`. `patio_de_juegos.tscn` conservaba ese override del panel antiguo. Se eliminó y se actualizaron los índices de sus otros overrides. Al reabrir el mismo proyecto con Godot 4.7.2 dejaron de aparecer tanto el aviso de nodo eliminado como el mensaje de Unicode.

### Guía visual de salida de la misión 2

La instrucción escrita se sustituye por un halo dorado y una mano pixelada que demuestra dos toques con anillos, en ciclos suaves. La puerta aparece después de terminar la última retroalimentación y se habilita al acabar su desvanecido. Ratón y foco de teclado resaltan la puerta; la activación expande la luz durante 0.45 segundos y bloquea pulsaciones repetidas antes de continuar al cuestionario o al mapa de rejugabilidad.

Se actualizó `_probar_memorias()` en `probar_revision_final.gd` para comprobar el orden de aparición, la ausencia del letrero, las áreas decorativas que no interceptan eventos y la separación respecto a fotografías y contador. `capturar_revision.gd` espera ahora la reflexión completa antes de capturar la puerta.

Validación focalizada con Godot 4.7.2 y Vulkan Forward Mobile: 29 comprobaciones aprobadas, incluidos clic real en el viewport, margen transparente, teclado, toque de pantalla simulado, protección frente a activaciones repetidas y los destinos de historia y rejugabilidad. Se revisaron capturas a 1920×1080 y 854×480. Sin errores de script ni recursos en esa ejecución; datos de usuario separados mediante APPDATA temporal.
