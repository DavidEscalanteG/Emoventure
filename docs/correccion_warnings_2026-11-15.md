# Advertencias del tutorial y reposo de NPC — 15 de noviembre de 2026

Se corrigieron las causas de las advertencias compartidas, sin desactivar
categorías de GDScript ni ocultar avisos del juego.

- `is_visible` se renombró a `should_show`: ya no coincide con el método
  heredado de CanvasLayer.
- Los parámetros y variables `size` del suelo del tutorial se llaman
  `arena_size`, para distinguirlos de la propiedad de Control.
- El patrón de baldosas usa división decimal y `floori` explícito. Conserva
  los mismos índices para las coordenadas positivas del dibujo.
- El material del fondo se llama `background_material`, sin coincidir con
  la propiedad heredada de CanvasItem.
- El servicio de animación reconoce reposos `idle`, direccionales en inglés
  o español y las posturas `default`. El payaso vuelve a `idle_derecha` o
  `idle_izquierda`, conservando el lado; Fran vuelve a su postura neutra
  `default`. También se admite su variante local `default_down`.

## Pruebas en Godot 4.5.2

La suite `probar_reposo_npc.gd` mueve actores reales y comprueba su posición
final, animación de reposo y existencia de fotogramas. Incluye ambos lados del
payaso, los dos desplazamientos de Fran en el rescate y su variante de la
escena 9: **21 comprobaciones aprobadas**. Antes había cinco advertencias en
esos casos válidos; después, cero. Un actor incompleto artificial genera una
advertencia capturada por la prueba, para verificar que se conserva la
detección de errores reales. Esa advertencia intencional no se imprime al motor.

El tutorial del laberinto y el primer mapa arrancaron durante 180 pasos de
física cada uno, sin diagnósticos. La carga e instanciación de **277 recursos**
terminó con cero fallos. Se usaron perfiles APPDATA temporales.

La importación general del editor encontró un error del complemento Dialogue
Manager al recorrer una carpeta no accesible en este entorno; no se presenta
como una validación global limpia. Las pruebas específicas anteriores sí
terminaron correctamente.

Registros: `pruebas/resultados/warnings_2026-11-15/`. Los cambios requieren un
nuevo despliegue para verificarlos durante un recorrido completo en teléfono.
