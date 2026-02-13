# Flujo técnico de escenas — Emoventure

Este documento resume el flujo narrativo-operativo implementado actualmente y valida las transiciones entre escenas con base en el documento de investigación (`docs/investigacion_texto_plano.md`).

## 1) Secuencia exacta de escenas (menú → selección → personalización → misiones → cuestionarios → llaves → cierre)

1. **Menú principal**  
   `res://scenes/menu_principal/menu_principal.tscn`

2. **Selección de género**  
   `res://scenes/escena_seleccion_genero/seleccion_genero.tscn`

3. **Personalización de avatar**  
   `res://scenes/personalizacion/Personalizacion.tscn`

4. **Intro narrativa (escena 1)**  
   `res://scenes/escena_1/escena_1.tscn`

5. **Intro narrativa (escena 2)**  
   `res://scenes/escena_2/escena_2.tscn`

6. **Misión 1 — recolección de emociones (mapa)**  
   `res://scenes/escena_3/mapa_1/escena_3.tscn`

7. **Cuestionario 1 (dimensión: atención)**  
   `res://scenes/cuestionario/EscenaCuestionario.tscn`

8. **Llave 1 (intermedia)**  
   `res://scenes/escena_4_llave/PrimeraLlave.tscn`

9. **Transición narrativa post-misión 1**  
   `res://scenes/escena_5/escena_5.tscn`

10. **Transición narrativa**  
	`res://scenes/escena_6/escena_6.tscn`
	
11. **Transición narrativa**  
	`res://scenes/escena_7/escena_7.tscn`
	
12. **Intro misión 2**  
	`res://scenes/escena_8/escena_8.tscn`
	
13. **Misión 2 — memorias eternas**  
	`res://scenes/escena_9/escena_9.tscn`
	
14. **Cuestionario 2 (dimensión: atención, temporal mientras se parametriza por misión)**  
	`res://scenes/cuestionario/EscenaCuestionario.tscn`
	
15. **Llave 2 (intermedia)**  
	`res://scenes/escena_10_llave/escena_10.tscn`
	
16. **Cierre actual (provisional)**  
	`res://scenes/menu_principal/menu_principal.tscn`

> Nota: El documento de investigación describe una tercera misión (pasillo). En el estado actual del repositorio, el flujo implementado termina de forma provisional regresando al menú después de la segunda llave.

## 2) Validación de transiciones en scripts `scenes/escena_*/*.gd`

### Coincidencias correctas con el flujo narrativo

- `escena_1.gd` → `escena_2.tscn`.
- `escena_2.gd` → `escena_3.tscn` (Misión 1).
- `escena_5.gd` → `escena_6.tscn`.
- `escena_6.gd` → `escena_7.tscn`.
- `escena_7.gd` → `escena_8.tscn`.
- `escena_8.gd` → `escena_9.tscn` (Misión 2).
- `primera_llave.gd` y `segunda_llave.gd` usan `@export var siguiente_escena` para desacoplar transición.
- `puerta_cuestionario.gd` y `escena_cuestionario.gd` usan `PackedScene` (`escena_siguiente`) para encadenar cuestionario→siguiente escena.

### Ajustes realizados para alinear el flujo

1. **Cuestionario 1 → Llave 1 (faltaba enlace intermedio)**  
   Se reasignó `escena_siguiente` de `NivelCompletadoUI.tscn` para que apunte a `PrimeraLlave.tscn` (antes iba directo a `escena_5.tscn`).

2. **Llave 2 → Cierre (faltaba export en `.tscn`)**  
   Se añadió `siguiente_escena` en `escena_10.tscn` apuntando al cierre actual (menú principal).

## 3) Variables export de transición completadas en `.tscn`

- `assets/assets_escena_3/UI/NivelCompletadoUI.tscn`  
  `escena_siguiente = ExtResource("3_6w4pf")` ahora referencia `res://scenes/escena_4_llave/PrimeraLlave.tscn`.

- `scenes/escena_10_llave/escena_10.tscn`  
  Se agregó `siguiente_escena = "res://scenes/menu_principal/menu_principal.tscn"` en el nodo raíz con script `segunda_llave.gd`.

## 4) Diagrama de estados (mantenible)

| Escena actual | Condición de salida | Siguiente escena |
|---|---|---|
| `menu_principal.tscn` | Click en botón comenzar | `escena_seleccion_genero.tscn` |
| `escena_seleccion_genero.tscn` | Elegir hombre/mujer | `Personalizacion.tscn` |
| `Personalizacion.tscn` | Confirmar avatar (botón comenzar) | `escena_1.tscn` |
| `escena_1.tscn` | Fin de diálogo | `escena_2.tscn` |
| `escena_2.tscn` | Fin de diálogo | `escena_3.tscn` |
| `escena_3.tscn` | Recolectar emociones y continuar | `EscenaCuestionario.tscn` |
| `EscenaCuestionario.tscn` (M1) | Responder todas las preguntas | `PrimeraLlave.tscn` |
| `PrimeraLlave.tscn` | Botón continuar | `escena_5.tscn` |
| `escena_5.tscn` | Fin de diálogo | `escena_6.tscn` |
| `escena_6.tscn` | Fin de diálogo | `escena_7.tscn` |
| `escena_7.tscn` | Fin de diálogo | `escena_8.tscn` |
| `escena_8.tscn` | Fin de diálogo | `escena_9.tscn` |
| `escena_9.tscn` | Completar 7 recuerdos y entrar por puerta | `EscenaCuestionario.tscn` |
| `EscenaCuestionario.tscn` (M2) | Responder todas las preguntas | `escena_10.tscn` |
| `escena_10.tscn` | Botón continuar | `menu_principal.tscn` (cierre provisional) |
