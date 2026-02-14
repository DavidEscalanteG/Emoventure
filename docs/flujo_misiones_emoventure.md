# Flujo técnico de escenas — Emoventure

Este documento resume el flujo narrativo-operativo implementado actualmente y valida las transiciones entre escenas a partir de los scripts vigentes.

## 1) Secuencia de escenas implementada (estado actual)

1. **Menú principal**  
   `res://scenes/menu_principal/menu_principal.tscn`
2. **Selección de género**  
   `res://scenes/escena_seleccion_genero/seleccion_genero.tscn`
3. **Personalización de avatar**  
   `res://scenes/personalizacion/Personalizacion.tscn`
4. **Escena narrativa 1**  
   `res://scenes/escena_1/escena_1.tscn`
5. **Escena narrativa 2**  
   `res://scenes/escena_2/escena_2.tscn`
6. **Misión 1 — recolección de emociones**  
   `res://scenes/escena_3/mapa_1/escena_3.tscn`
7. **Cuestionario (misión 1)**  
   `res://scenes/cuestionarios/EscenaCuestionario.tscn`
8. **Llave 1**  
   `res://scenes/escena_4_llave/PrimeraLlave.tscn`
9. **Escena narrativa 5**  
   `res://scenes/escena_5/escena_5.tscn`
10. **Escena narrativa 6**  
	`res://scenes/escena_6/escena_6.tscn`
11. **Escena narrativa 7**  
	`res://scenes/escena_7/escena_7.tscn`
12. **Intro misión 2**  
	`res://scenes/escena_8/escena_8.tscn`
13. **Misión 2 — memorias eternas**  
 `res://scenes/escena_9/escena_9.tscn`
14. **Cuestionario (misión 2)**  
	`res://scenes/cuestionarios/EscenaCuestionario.tscn`
15. **Llave 2**  
	`res://scenes/escena_10_llave/escena_10.tscn`
16. **Misión 3 — pasillo con hachas**  
	`res://scenes/escena_11_mision_3/escena_11_mision_3.tscn`
17. **Recompensa misión 3 (llave + mazo)**  
	`res://scenes/escena_12_recompensa_m3/recompensa_mision_3.tscn`
18. **Retorno a menú (temporal)**  
	`res://scenes/menu_principal/menu_principal.tscn`

## 2) Validación de scripts solicitados

### `scenes/escena_11_mision_3/mision_3.gd`
- Define `escena_recompensa` con destino por defecto `res://scenes/escena_12_recompensa_m3/recompensa_mision_3.tscn`.
- La salida solo cambia de escena cuando se activaron los 2 checkpoints (`progreso_actual >= 2`) y el jugador entra al área de salida.

### `scenes/escena_12_recompensa_m3/recompensa_mision_3.gd`
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
| `escena_11_mision_3.tscn` | Jugador llega a salida con 2 checkpoints | `recompensa_mision_3.tscn` | `mision_3.gd` (`escena_recompensa`, `_on_salida_body_entered`) |
| `recompensa_mision_3.tscn` | Botón continuar | `menu_principal.tscn` | `recompensa_mision_3.gd` (`siguiente_escena`, `_on_boton_continuar_pressed`) |
| `mapa_topos.tscn` (misión 4) | Victoria + completar cuestionario | `resultado_final.tscn` | `mapa_topos.tscn` (`escena_cierre`) + `mapa_topos.gd` (`_iniciar_cuestionario`, `cuestionario.escena_siguiente = escena_cierre`) |
| `resultado_final.tscn` | Botón “Volver al menú principal” | `menu_principal.tscn` | `resultado_final.gd` (`_on_boton_menu_principal_pressed`) |

## 5) Nota de compatibilidad y criterio de retiro

- **Transición temporal activa:** `recompensa_mision_3.tscn` → `menu_principal.tscn`.
- **Motivo de compatibilidad:** mantiene jugable el cierre de la rama de misión 3 sin obligar a pasar por misión 4.
- **Criterio de retiro:** eliminar esta transición cuando la salida de misión 3 se conecte formalmente a la secuencia final del producto (por ejemplo, encadenar a misión 4 o al `resultado_final.tscn` según diseño definitivo) y se valide QA de regresión de flujo completo.
