# Flujo técnico de escenas — Emoventure

Este documento resume el flujo narrativo-operativo implementado actualmente y valida las transiciones entre escenas a partir de los scripts vigentes.

## 1) Secuencia de escenas implementada (estado actual)

1. **Menú principal**  
   `res://scenes/menu_principal/menu_principal.tscn`
2. **Selección de género**  
   `res://scenes/intro_seleccion_genero/intro_seleccion_genero.tscn`
3. **Personalización de avatar**  
   `res://scenes/personalizacion/Personalizacion.tscn`
4. **Escena narrativa 1**  
   `res://scenes/intro_dialogo_1/intro_dialogo_1.tscn`
5. **Escena narrativa 2**  
   `res://scenes/intro_dialogo_2/intro_dialogo_2.tscn`
6. **Misión 1 — recolección de emociones**  
   `res://scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn`
7. **Cuestionario (misión 1)**  
   `res://scenes/cuestionarios/EscenaCuestionario.tscn`
8. **Llave 1**  
   `res://scenes/transicion_post_mision_1/transicion_post_mision_1.tscn`
9. **Escena narrativa 5**  
   `res://scenes/intro_dialogo_3/intro_dialogo_3.tscn`
10. **Escena narrativa 6**  
	`res://scenes/intro_dialogo_4/intro_dialogo_4.tscn`
11. **Escena narrativa 7**  
	`res://scenes/intro_dialogo_5/intro_dialogo_5.tscn`
12. **Intro misión 2**  
	`res://scenes/intro_mision_2/intro_mision_2.tscn`
13. **Misión 2 — memorias eternas**  
 `res://scenes/mision_2_memorias/mision_2_memorias.tscn`
14. **Cuestionario (misión 2)**  
	`res://scenes/cuestionarios/EscenaCuestionario.tscn`
15. **Llave 2**  
	`res://scenes/transicion_post_mision_2/transicion_post_mision_2.tscn`
16. **Misión 3 — pasillo con hachas**  
	`res://scenes/mision_3_hachas/mision_3_hachas.tscn`
17. **Recompensa misión 3 (llave + mazo)**  
	`res://scenes/recompensa_mision_3/recompensa_mision_3.tscn`
18. **Retorno a menú (temporal)**  
	`res://scenes/menu_principal/menu_principal.tscn`

## 2) Validación de scripts solicitados

### `scenes/mision_3_hachas/mision_3_hachas.gd`
- Define `escena_recompensa` con destino por defecto `res://scenes/recompensa_mision_3/recompensa_mision_3.tscn`.
- La salida solo cambia de escena cuando se activaron los 2 checkpoints (`progreso_actual >= 2`) y el jugador entra al área de salida.

### `scenes/recompensa_mision_3/recompensa_mision_3.gd`
- Define `siguiente_escena` con destino por defecto `res://scenes/menu_principal/menu_principal.tscn`.
- El botón de continuar ejecuta `change_scene_to_file(siguiente_escena)`.

### `scenes/final/resultado_final.gd`
- Implementa el **cierre definitivo** en `res://scenes/final/resultado_final.tscn`.
- El botón final reinicia estado (`GameManager.reiniciar_puntajes()` y, si existe, `DatosJugador.reiniciar_estado_temporal()`) y luego vuelve al menú principal.

## 3) Cierre de juego: definitivo vs temporal

- **Cierre definitivo existente:** `res://scenes/final/resultado_final.tscn` (script `resultado_final.gd`).
- **Cierre actualmente conectado tras misión 3:** retorno directo a menú desde `recompensa_mision_3.gd`.

En consecuencia, el “cierre provisional” se reemplaza en este documento por dos estados explícitos:
1. **Cierre definitivo disponible en código** (escena final).
2. **Retorno temporal activo en el flujo de misión 3** (menú principal).

## 4) Flujo validado en código

| Origen | Disparador | Destino | Evidencia en código |
|---|---|---|---|
| `mision_3_hachas.tscn` | Jugador llega a salida con 2 checkpoints | `recompensa_mision_3.tscn` | `mision_3_hachas.gd` (`escena_recompensa`, `_on_salida_body_entered`) |
| `recompensa_mision_3.tscn` | Botón continuar | `menu_principal.tscn` | `recompensa_mision_3.gd` (`siguiente_escena`, `_on_boton_continuar_pressed`) |
| `mapa_topos.tscn` (misión 4) | Victoria + completar cuestionario | `resultado_final.tscn` | `mapa_topos.tscn` (`escena_cierre`) + `mapa_topos.gd` (`_iniciar_cuestionario`, `cuestionario.escena_siguiente = escena_cierre`) |
| `resultado_final.tscn` | Botón “Volver al menú principal” | `menu_principal.tscn` | `resultado_final.gd` (`_on_boton_menu_principal_pressed`) |

## 5) Nota de compatibilidad y criterio de retiro

- **Transición temporal activa:** `recompensa_mision_3.tscn` → `menu_principal.tscn`.
- **Motivo de compatibilidad:** mantiene jugable el cierre de la rama de misión 3 sin obligar a pasar por misión 4.
- **Criterio de retiro:** eliminar esta transición cuando la salida de misión 3 se conecte formalmente a la secuencia final del producto (por ejemplo, encadenar a misión 4 o al `resultado_final.tscn` según diseño definitivo) y se valide QA de regresión de flujo completo.
