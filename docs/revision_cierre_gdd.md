# Revisión de cierre y acuerdos del GDD — 28 de octubre de 2026

## Alcance aprobado

El usuario confirmó que las diferencias de la auditoría inicial corresponden a acuerdos con el equipo del GDD:

- M1 conserva los colores finales representativos, incluida alegría amarilla y sin transformación a gris.
- M3 usa avance automático y saltos, con estilo Geometry Dash. La versión de hachas queda como implementación anterior.
- M4 usa puntos o proporción de aciertos y permite omitir después de varios intentos. En esta revisión el usuario pidió **conservar el umbral actual: 40 puntos O 50 % de aciertos**; omisión desde el cuarto intento.
- El rescate con Frankenstein y el cierre actual son adaptaciones aceptadas.
- La personalización ampliada sigue siendo opcional; esta revisión evalúa su viabilidad, sin incorporar un catálogo nuevo.

Estos acuerdos actualizan la interpretación de la auditoría inicial. No se modificó el documento de Drive.

## Correcciones implementadas

### Estado entre partidas

Nueva partida y carga de otro slot limpian checkpoint, posición, tiempo musical y muertes de M3, intentos de M4, modo de rejugabilidad y cuestionario pendiente anterior. La carga restaura después los datos del slot elegido.

Un nuevo recorrido desde rejugabilidad también comienza limpio. Reiniciar el mismo recorrido por una muerte conserva su checkpoint e intentos. Los checkpoints continúan siendo temporales: no se añaden campos al formato de guardado y al cargar un slot se inicia la escena guardada desde el comienzo, sin heredar una posición de otra partida.

### Payasos

Solo se cuentan apariciones que realmente comenzaron en una instancia disponible. Un payaso visible no puede aumentar el denominador de precisión. Un doble golpe en la misma aparición suma una sola vez.

Al reiniciar, se cancelan los movimientos anteriores para impedir que un callback antiguo oculte al payaso recién aparecido. Se evita que la aceleración reduzca el intervalo por debajo del mínimo configurado.

Omitir la misión detiene sus temporizadores, restaura el cursor y abre el cuestionario una sola vez. Permanecen intactos los umbrales y el cuarto intento de omisión.

### Resultados

Se sustituyeron los mensajes genéricos por los criterios de `investigacion_texto_plano.md`, respetando los intervalos inclusivos. El código ya incluía los valores iguales a los límites; la prueba nueva verifica todas las puntuaciones válidas, de 8 a 40, para las tres dimensiones y ambos géneros.

| Dimensión | Género | Bajo | Adecuado | Alto |
|---|---|---|---|---|
| Atención | Hombre | ≤21 | 22–32 | ≥33 |
| Atención | Mujer | ≤24 | 25–35 | ≥36 |
| Claridad | Hombre | ≤25 | 26–35 | ≥36 |
| Claridad | Mujer | ≤23 | 24–34 | ≥35 |
| Reparación | Hombre | ≤23 | 24–35 | ≥36 |
| Reparación | Mujer | ≤23 | 24–34 | ≥35 |

Atención baja indica poca atención; atención alta indica demasiada atención: ambas recomiendan mejorarla. Claridad y reparación bajas recomiendan mejorar; sus intervalos superiores muestran adecuada o excelente claridad/reparación.

El resumen reconoce empates dobles y triples; cuando hay un máximo único habla de la puntuación más alta, sin atribuir automáticamente una identidad emocional. La pantalla y el PDF comparten las mismas funciones de interpretación.

### Arranque

Se reprodujo un error al ejecutar la escena inicial fuera de Web: intentaba sustituirse por el menú dentro de `_ready`, mientras el árbol todavía incorporaba nodos. El cambio al menú ahora se difiere. El arranque real ya llega al menú; la prueba nueva incluye esa ruta.

Se actualizaron el flujo, la matriz de transiciones, la arquitectura y la trazabilidad emocional para reflejar las escenas activas.

## Misión 2: recomendación

Mantendría su mecánica principal, las siete imágenes y la libertad de asignar cualquier emoción. No se encontró una modificación obligatoria para cumplir el alcance acordado.

Como mejora opcional, permitiría reabrir una fotografía ya confirmada para cambiar la emoción antes de salir. Ahora se impide abrirla cuando está completada. Habría que conservar el contador en siete, reemplazar la respuesta previa y actualizar su representación visual; cambiar de opinión no debería duplicar progreso ni calificarse como error.

## Personalización: viabilidad real

Se inspeccionaron los recursos existentes y se hizo una prueba visual de combinaciones de ropa y sombreros en reposo/movimiento.

- La escena del jugador ya dispone de colecciones para dos piezas de ropa y tres opciones de sombrero, incluida la opción vacía.
- Las dos prendas y los dos sombreros visibles tienen animaciones de reposo y caminar en las cuatro direcciones.
- La segunda ropa y los sombreros no contienen las ocho animaciones emocionales del cuerpo. La ropa alternativa tampoco representa un atuendo completo equivalente al actual en la prueba visual.
- La opción vacía de sombrero tiene distintos conteos de fotogramas, por lo que no se debe asumir correspondencia automática en todas las piezas.
- Las piezas comparten el sistema de hojas de 64 × 64, lo que facilita una ampliación pequeña. Aun así, hay que revisar poses emocionales, capas de cabello, tintes, recortes, miniaturas, guardado y aparición en las cinemáticas.

Es viable ampliar gradualmente con sombreros y prendas compatibles. No se considera que todo esté listo con solo exponer flechas en el menú. Crear complexiones, zapatos, lentes o collares nuevos y garantizar calidad en todas las poses es trabajo de arte y adaptación por fotograma; no se promete como un cambio pequeño.

## Peso y limpieza

La medición separa archivos fuente, historial de Git, caché local y paquete exportado. MiB significa 1 048 576 bytes.

| Medición | Tamaño aproximado |
|---|---:|
| Archivos actualmente versionados | 200,1 MiB |
| Audios en el proyecto | 89,3 MiB |
| Documentación | 62,2 MiB |
| Assets | 33,5 MiB |
| Escenas y recursos propios de escenas | 12,3 MiB |
| Caché local `.godot` | 165,6 MiB |
| Paquetes del historial de Git (`size-pack`) | 324,5 MiB |
| ZIP de recursos con el preset Web actual | 122,6 MiB |
| Candidatos sin alcance estático desde el juego | 20,1 MiB en 870 archivos |
| Parte de esos candidatos presente en el ZIP, comprimida | 12,5 MiB, alrededor del 10,2 % |

La exportación es un ZIP de recursos para medir, no un APK ni una distribución Web completa. El paquete se generó antes de corregir el arranque y se conserva su inventario de contenido como evidencia. Se registraron diagnósticos del editor sobre guardado seguro y la exploración de carpetas del plugin de diálogos; no se presenta como una exportación sin diagnósticos.

El análisis sigue rutas literales `res://`, UIDs, autoloads y clases globales, e incluye referencias comentadas y prefijos de directorios de forma conservadora. **No demuestra que los 870 archivos puedan eliminarse sin revisión.** Hay que considerar herramientas del editor, guardados de versiones antiguas y futuras piezas de personalización.

Los dos presets exportan todos los recursos. Entre los mayores candidatos encontrados están:

| Archivo | Fuente | Comprimido en el ZIP |
|---|---:|---:|
| `assets/audio/music/Breezy Puzzle Loop.mp3` | 4,53 MiB | 4,52 MiB |
| `assets/audio/music/Puzzle Dance (@fowksprod).mp3` | 2,36 MiB | 2,29 MiB |
| `assets/fondo8.jpg` | 2,22 MiB | 3,09 MiB |

También hay variantes antiguas de M3, imágenes de pruebas y copias terminadas en `~`. Estas últimas ocupan fuente aunque no necesariamente entren en la exportación. El PDF grande de investigación no apareció en el ZIP: retirarlo del proyecto reduciría la copia de trabajo, pero no ese paquete del juego.

**No borrar `pruebas/` completa:** al menos 51 archivos de esa carpeta siguen conectados al juego, incluidas animaciones y mascotas. La carpeta `.godot` y los temporales ya están ignorados por Git. Borrar archivos actuales tampoco elimina sus versiones del historial: no se propone reescribir Git para una reducción relativamente pequeña.

La limpieza recomendable es separar documentación y archivos de trabajo, revisar primero los candidatos grandes, mover a una biblioteca externa los recursos que se quieran conservar y validar el conjunto exportado antes de retirar fuentes. No se eliminaron recursos existentes ni se cambiaron filtros de exportación en esta revisión.

## Verificación

Motor disponible: Godot 4.7.2. Perfil de pruebas aislado mediante APPDATA.

- Prueba nueva: **240 comprobaciones aprobadas en headless**, y **241 con render OpenGL y captura de resultados**.
- Funcionamiento existente: 41 comprobaciones aprobadas.
- Revisión final: 372 comprobaciones aprobadas.
- Personalización: 517 comprobaciones aprobadas.
- Carga e instanciación: 265 recursos, cero fallos.
- Cuestionarios: 24 preguntas legibles sin recortes.
- PDF: siete documentos con texto, acentos, contenido y márgenes correctos; se inspeccionó un render del perfil bajo con empate.
- Se inspeccionó la pantalla de resultados con mujer, atención 36, claridad 23 y reparación 35.
- `git diff --check` correcto.

Algunas suites existentes y el cierre directo del menú siguen informando recursos pendientes al salir; la prueba nueva termina sin esos diagnósticos. Quedan pendientes una partida manual completa, pruebas en Android/Web reales y diagnóstico de esos recursos.

## Comando de regresión

```powershell
$env:APPDATA = Join-Path (Get-Location) ".tmp_godot_cierre/perfil"
godot_console --headless --path . --script res://pruebas/validacion/probar_cierre_gdd.gd
```

La prueba desactiva el guardado automático y usa slots en memoria; el perfil aislado evita leer partidas reales. La variable opcional `CODEX_CIERRE_CAPTURA` permite guardar una captura al ejecutarla con render, sin `--headless`.

