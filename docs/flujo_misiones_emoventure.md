# Flujo técnico de escenas — Emoventure

Documento de referencia del flujo narrativo/jugable según scripts y escenas actuales.

## 1) Punto de entrada y menú

1. `res://scenes/menu_principal/menu_principal.tscn` (escena inicial, definida en `project.godot`).
2. Desde menú principal existen tres rutas directas:
   - **Comenzar** → `res://scenes/intro_seleccion_genero/intro_seleccion_genero.tscn`
   - **Configuración** → `res://scenes/configuracion/configuracion.tscn`
   - **Créditos** → `res://scenes/creditos/creditos.tscn`

## 2) Flujo narrativo principal (primera partida)

1. `intro_seleccion_genero.tscn`
2. `Personalizacion.tscn`
3. `intro_dialogo_1.tscn`
4. `intro_dialogo_2.tscn`
5. **Misión 1 (recolección)**: `mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn` (la selección real del mapa usa rotación aleatoria del `GameManager`, puede enviar a `mapa_1..mapa_5`).
6. `EscenaCuestionario.tscn` (misión 1)
7. `transicion_post_mision_1.tscn`
8. `intro_dialogo_3.tscn`
9. `intro_dialogo_4.tscn`
10. `intro_dialogo_5.tscn`
11. `intro_mision_2.tscn`
12. `mision_2_memorias.tscn`
13. `EscenaCuestionario.tscn` (misión 2)
14. `transicion_post_mision_2.tscn`
15. `mision_3_hachas.tscn`
16. `EscenaCuestionario.tscn` (misión 3, bloque reparación ítems 1–4)
17. `recompensa_mision_3.tscn`
18. `mision_4_payasos/mapa_topos.tscn`
19. `EscenaCuestionario.tscn` (misión 4, bloque reparación ítems 5–8)
20. `final/resultado_final.tscn`
21. `rejugabilidad/mapa_rejugabilidad.tscn`

## 3) Estado de cierre actual

- `resultado_final.gd` **ya no vuelve al menú principal** al pulsar continuar.
- El botón de salida de resultados va a `res://scenes/rejugabilidad/mapa_rejugabilidad.tscn`.
- Desde rejugabilidad se puede:
  - relanzar minijuegos 1–4,
  - o volver a `resultado_final.tscn` con el botón de retorno.

## 4) Flujos alternativos detectados

- Existe una ruta narrativa disponible de forma independiente en scripts:
  - `intro_mision_4.tscn` → `mision_4_payasos/mapa_topos.tscn`.
- Los tutoriales de minijuego (`Minijuego1_Tutorial.tscn`, `Minijuego2_Tutorial.tscn`) existen como escenas de apoyo y su controlador redirige a la escena de misión correspondiente.

## 5) Reglas técnicas clave del flujo

- Cuestionarios por misión:
  - M1 = atención
  - M2 = claridad
  - M3 = reparación (ítems 1–4)
  - M4 = reparación (ítems 5–8)
- En modo rejugabilidad (`GameManager.activar_modo_rejugabilidad()`), algunas escenas saltan cuestionario y regresan al mapa de rejugabilidad.
- `GameManager` administra rotación de mapas para Misión 1 (`mapa_1` a `mapa_5`).

## 6) Archivos base auditados para esta versión

- `project.godot`
- `src/autoload/game_manager.gd`
- `scenes/menu_principal/*.gd`
- `scenes/creditos/creditos.gd`
- `scenes/intro_*/**/*.gd`
- `scenes/mision_*/**/*.gd`
- `scenes/cuestionarios/escena_cuestionario.gd`
- `scenes/final/resultado_final.gd`
- `scenes/rejugabilidad/mapa_rejugabilidad.gd`
