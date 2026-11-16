# Error can_process durante transiciones — 15 de noviembre de 2026

Se reprodujo el aviso reportado en Godot **4.5.2**, usando contactos del
viewport en la copia móvil del proyecto y perfiles APPDATA temporales.

## Causa reproducida

Una pulsación táctil incluye eventos de contacto y ratón emulado. Algunos
botones cambiaban la escena inmediatamente desde su señal, retirando los
controles del árbol antes de terminar la entrada. El viewport conservaba
el destino del contacto y consultaba `can_process()` en un control que ya
había salido del árbol. El motor imprimía `!is_inside_tree()` y devolvía false.

El recorrido de victoria → cuestionario → primera llave → diálogo, más la
segunda llave, produjo **nueve avisos** en tres tamaños de ventana. Al aplazar
esas transiciones con `call_deferred`, el mismo recorrido produjo **cero**.

## Cambio

Las llamadas directas de transición y reinicio de las escenas del juego ahora
se programan al terminar el evento, mediante:

```gdscript
get_tree().change_scene_to_file.call_deferred(destino)
```

El cambio equivalente se aplica a `change_scene_to_packed` y al reinicio del
laberinto. Se mantienen las rutas y las señales existentes. La meta del antiguo
plataformero conserva su comprobación del código Error: su método `_avanzar`
ya se invocaba de forma diferida después de la consulta de física.

## Verificación

- Recorrido móvil: **189 comprobaciones, cero fallos**; avisos can_process:
  **9 antes, 0 después**.
- Suite `probar_cambios_escena.gd`: **30 comprobaciones, cero fallos** y cero
  avisos can_process en menús, configuración, créditos, selección, final de
  diálogo y salida de pausa. Comprueba que la escena sigue dentro del árbol
  durante el evento y se libera al completar la transición.
- Carga e instanciación: **276 recursos, cero fallos**.
- Suite de funcionamiento: **cero fallos** en movimiento, pausa, reinicio,
  recorrido de diez niveles, cuestionario, rejugabilidad y controles.

Los ensayos headless de recorrido, menús y funcionamiento informaron recursos
pendientes de liberar al cerrar el proceso de prueba; también sucedía antes
del cambio. Ese diagnóstico de cierre se distingue del aviso can_process
reproducido durante el juego. No se presenta la salida completa como libre
de otros diagnósticos.

Registros: `pruebas/resultados/cambios_escena_2026-11-15/`. La corrección está
en el código del proyecto y requiere volver a exportar/desplegar para probarla
en el teléfono. No se actualizó la aplicación del teléfono durante esta revisión.

Referencia del motor: [tratamiento de contacto y ratón en Viewport de Godot 4.5.2](https://github.com/godotengine/godot/blob/4.5.2-stable/scene/main/viewport.cpp).
