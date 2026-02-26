# Flujo técnico de escenas — Emoventure

Este documento resume el flujo narrativo-operativo implementado actualmente y valida las transiciones entre escenas a partir de los scripts vigentes.

## 1) Secuencia de escenas implementada (estado actual)

1. **Menú principal**  
   `res://scenes/main_menu/menu_principal/menu_principal.tscn`
2. **Selección de género**  
   `res://scenes/tutorials/intro_seleccion_genero/intro_seleccion_genero.tscn`
3. **Personalización de avatar**  
   `res://scenes/personalizacion/Personalizacion.tscn`
4. **Escena narrativa 1**  
   `res://scenes/tutorials/intro_dialogo_1/intro_dialogo_1.tscn`
5. **Escena narrativa 2**  
   `res://scenes/tutorials/intro_dialogo_2/intro_dialogo_2.tscn`
6. **Misión 1 — recolección de emociones**  
   `res://scenes/minigames/minigame_1/mapa_1/mision_1_recoleccion.tscn`
7. **Cuestionario (misión 1)**  
   `res://scenes/cuestionarios/EscenaCuestionario.tscn`
8. **Llave 1**  
   `res://scenes/transicion_post_mision_1/transicion_post_mision_1.tscn`
9. **Escena narrativa 5**  
   `res://scenes/tutorials/intro_dialogo_3/intro_dialogo_3.tscn`
10. **Escena narrativa 6**  
	`res://scenes/tutorials/intro_dialogo_4/intro_dialogo_4.tscn`
11. **Escena narrativa 7**  
	`res://scenes/tutorials/intro_dialogo_5/intro_dialogo_5.tscn`
12. **Intro misión 2**  
	`res://scenes/tutorials/intro_mision_2/intro_mision_2.tscn`
13. **Misión 2 — memorias eternas**  
 `res://scenes/minigames/minigame_2/mision_2_memorias.tscn`
14. **Cuestionario (misión 2)**  
	`res://scenes/cuestionarios/EscenaCuestionario.tscn`
15. **Llave 2**  
	`res://scenes/transicion_post_mision_2/transicion_post_mision_2.tscn`
16. **Misión 3 — pasillo con hachas**  
	`res://scenes/minigames/minigame_3/mision_3_hachas.tscn`
17. **Cuestionario (misión 3, reparación ítems 1–4)**  
	`res://scenes/cuestionarios/EscenaCuestionario.tscn`
18. **Recompensa misión 3 (llave + mazo)**  
	`res://scenes/recompensa_mision_3/recompensa_mision_3.tscn`
19. **Misión 4 — topos (rescate final)**
	`res://scenes/minigames/minigame_4/mapa_topos.tscn`
20. **Resultado final**
	`res://scenes/results/final/resultado_final.tscn`

## 2) Validación de scripts solicitados

### `scenes/mision_3_hachas/mision_3_hachas.gd`
- Define `escena_cuestionario` y `numero_mision_cuestionario = 3` para inyectar el bloque de reparación (ítems 1–4).
- Tras activar 2 checkpoints y llegar a salida, instancia `EscenaCuestionario` y define como `escena_siguiente` la recompensa de misión 3.

### `scenes/recompensa_mision_3/recompensa_mision_3.gd`
- Define `siguiente_escena` con destino por defecto `res://scenes/minigames/minigame_4/mapa_topos.tscn`.
- El botón de continuar ejecuta `change_scene_to_file(siguiente_escena)`.

### `scenes/final/resultado_final.gd`
- Implementa el **cierre definitivo** en `res://scenes/results/final/resultado_final.tscn`.
- El botón final reinicia estado (`GameManager.reiniciar_puntajes()` y, si existe, `DatosJugador.reiniciar_estado_temporal()`) y luego vuelve al menú principal.

## 3) Cierre de juego y encadenamiento actual

- **Flujo activo tras misión 3:** cuestionario de reparación (ítems 1–4) → recompensa de misión 3 → misión 4 (topos).
- **Cierre definitivo:** `res://scenes/results/final/resultado_final.tscn` (script `resultado_final.gd`).

En el estado actual, la rama principal ya encadena a resultado final pasando por misión 4 y cuestionario correspondiente.

## 4) Flujo validado en código

| Origen | Disparador | Destino | Evidencia en código |
|---|---|---|---|
| `mision_3_hachas.tscn` | Jugador llega a salida con 2 checkpoints | `EscenaCuestionario.tscn` (misión 3) | `mision_3_hachas.gd` (`escena_cuestionario`, `_on_salida_body_entered`) |
| `EscenaCuestionario.tscn` (misión 3) | Responder 4 preguntas de reparación (ítems 1–4) | `recompensa_mision_3.tscn` | `escena_cuestionario.gd` + `mision_3_hachas.gd` (`escena_siguiente`) |
| `recompensa_mision_3.tscn` | Botón continuar | `mapa_topos.tscn` | `recompensa_mision_3.gd` (`siguiente_escena`, `_on_boton_continuar_pressed`) |
| `mapa_topos.tscn` (misión 4) | Victoria + completar cuestionario | `resultado_final.tscn` | `mapa_topos.tscn` (`escena_cierre`) + `mapa_topos.gd` (`_iniciar_cuestionario`, `cuestionario.escena_siguiente = escena_cierre`) |
| `resultado_final.tscn` | Botón “Volver al menú principal” | `menu_principal.tscn` | `resultado_final.gd` (`_on_boton_menu_principal_pressed`) |

## 5) Nota de compatibilidad y criterio de mantenimiento

- **Transición activa:** `recompensa_mision_3.tscn` → `mision_4_payasos/mapa_topos.tscn`.
- **Objetivo:** mantener continuidad del flujo principal hasta `resultado_final.tscn`.
- **Criterio de mantenimiento:** cualquier cambio de destino desde recompensa misión 3 debe actualizar esta guía y `docs/matriz_transiciones.md`, seguido de QA de regresión del flujo completo.


## 6) Matriz de transiciones (fuente de control)

- Mantener sincronizado este documento con `docs/matriz_transiciones.md`.
- Antes de cualquier refactor de nombres de escenas (`escena_X` → nombre semántico), actualizar primero la matriz y luego aplicar cambios de código.
- Usar la checklist manual de la matriz para validar el flujo completo en cada release.
