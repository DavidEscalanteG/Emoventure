# Validación de Emoventure (Godot 4.5)

Ejecutar desde la raíz del proyecto con Python y el ejecutable de consola de Godot 4.5:

```powershell
python pruebas/validacion/validar_proyecto.py --godot "C:/ruta/Godot_v4.5-stable_win64_console.exe" --smoke
```

`--project` permite indicar otra copia del proyecto. `--logs` permite elegir dónde conservar los registros; por defecto se crea una carpeta temporal. El comando devuelve un código distinto de cero ante errores, advertencias, conflictos de Git, cierres inesperados o pruebas incompletas. No basta con que Godot devuelva código cero: también se revisa su salida.

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
