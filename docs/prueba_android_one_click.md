# Prueba Android con One-click deploy

Verificación realizada el 28 de octubre de 2026 con el POCO X6 5G físico del usuario.

## Estado comprobado

- Teléfono detectado por USB y autorizado: modelo Android `23122PCD1G`.
- Editor abierto: Godot 4.5.1 stable, ejecutable `Godot_4.5.exe`.
- Plantillas Android de esa misma versión: instaladas.
- Android SDK: `C:/Users/david/AppData/Local/Android/Sdk`; ADB funciona.
- Java configurado en ese editor: JDK 25; se verificó el ejecutable directamente.
- Clave de depuración existente: disponible. Se conservó la identidad de firma.
- Preset `Android`: `runnable=true`, APK firmado y arquitectura `arm64-v8a`.
- Opción del editor «Despliegue con un clic - Borrar instalación previa»: desactivada.

No fue necesario cambiar el preset para habilitar One-click deploy. La ruta de exportación manual `./Emoventure.apk` ya la había establecido el usuario.

## Prueba ejecutada

Se generó `.tmp_godot_deploy/Emoventure-debug.apk` con el mismo Godot 4.5.1 y el preset Android. Se instaló por USB mediante `adb install -r`; resultado: `Success`. Se abrió la actividad de Emoventure y Android devolvió `Status: ok`.

Se confirmó el proceso de la aplicación en el teléfono y se capturó la pantalla. La captura mostró la personalización y el teclado Android. La prueba verifica exportación, instalación y arranque; no constituye una partida completa.

La prueba se realizó mediante las herramientas de exportación y ADB, no pulsando el botón One-click del editor. La captura de la ventana del editor fue inconsistente y no se usó como evidencia de una ejecución mediante ese botón.

## Cómo usarlo desde Godot

1. Mantener conectado el POCO por un cable USB de datos.
2. Desbloquear el teléfono y aceptar la autorización de depuración USB si vuelve a solicitarla.
3. Cerrar la ventana de Configuración del Editor para regresar al editor principal.
4. En la barra superior derecha, buscar el botón o selector de despliegue Android y elegir el dispositivo `23122PCD1G` / POCO.
5. Pulsar ese destino. Godot exportará, instalará y ejecutará el proyecto en el teléfono físico.
6. Si el teléfono solicita confirmar una instalación por USB, hacerlo en el propio teléfono.

El botón normal de reproducción/F5 ejecuta en la computadora. El destino Android de One-click deploy ejecuta en el teléfono.

Si Android no aparece, comprobar `adb devices`, revisar que Android siga marcado como Runnable en Proyecto → Exportar y confirmar Editor → Configuración del Editor → Exportar → Android. Si todo coincide, cerrar la configuración y volver a enfocar Godot; reiniciar el editor si su lista de dispositivos no se actualiza.

No activar el borrado de la instalación anterior para actualizar normalmente. Si aparece un conflicto de firma, revisar qué clave firmó la instalación existente antes de desinstalar, porque una desinstalación puede perder los guardados.

## Incidencia gráfica observada

El registro del POCO contiene errores `CopyShaderGLES3: Program linking failed` y varios `!is_inside_tree()`. La captura de personalización muestra fondo, controles y retrato, pero no el personaje de cuerpo completo. Esto requiere una investigación específica del render en Android/Godot 4.5.1; no se atribuye todavía una causa exacta.

La instalación y el arranque fueron correctos. No se presenta la ejecución como libre de errores gráficos.

Evidencias locales de diagnóstico: `.tmp_godot_deploy/telefono.log` y `.tmp_godot_deploy/menu_poco.png`. La carpeta temporal está excluida de Git.

## Referencias

- [One-click deploy de Godot](https://docs.godotengine.org/en/stable/tutorials/export/one-click_deploy.html)
- [Exportación Android en Godot 4.5](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_android.html)

