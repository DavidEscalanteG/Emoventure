# Matriz de transiciones de escenas

> Fuente operativa para validar flujo de juego y base obligatoria antes de cualquier refactor de nombres (`escena_X` → nombre semántico).

| escena_origen | trigger (botón, diálogo, puerta, checkpoint) | destino | archivo_fuente (script/tscn) |
|---|---|---|---|
| `menu_principal.tscn` | Botón **Comenzar** | `intro_seleccion_genero.tscn` | `scenes/menu_principal/comenzar.gd`, `scenes/menu_principal/menu_principal.tscn` |
| `intro_seleccion_genero.tscn` | Botón continuar de selección | `Personalizacion.tscn` | `scenes/intro_seleccion_genero/intro_seleccion_genero.gd` |
| `Personalizacion.tscn` | Botón **Comenzar** | `intro_dialogo_1.tscn` | `scenes/personalizacion/comenzar.gd` |
| `mision_1_recoleccion.tscn` | UI de nivel completado | `EscenaCuestionario.tscn` | `scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.gd` |
| `EscenaCuestionario.tscn` (misión 1) | Responder preguntas + botón continuar narrativa | `transicion_post_mision_1.tscn` | `scenes/cuestionarios/escena_cuestionario.gd`, `scenes/transicion_post_mision_1/primera_llave.gd` |
| `transicion_post_mision_1.tscn` | Botón continuar (llave) | `intro_dialogo_3.tscn` | `scenes/transicion_post_mision_1/primera_llave.gd` |
| `mision_2_memorias.tscn` | Puerta habilitada al completar memorias | `EscenaCuestionario.tscn` | `scenes/mision_2_memorias/puerta_cuestionario.gd`, `scenes/mision_2_memorias/memorias_eternas_gameplay.gd` |
| `EscenaCuestionario.tscn` (misión 2) | Responder preguntas + botón continuar narrativa | `transicion_post_mision_2.tscn` | `scenes/cuestionarios/escena_cuestionario.gd`, `scenes/transicion_post_mision_2/segunda_llave.gd` |
| `transicion_post_mision_2.tscn` | Botón continuar (llave) | `mision_3_hachas.tscn` | `scenes/transicion_post_mision_2/segunda_llave.gd` |
| `mision_3_hachas.tscn` | Salida + 2 checkpoints | `EscenaCuestionario.tscn` | `scenes/mision_3_hachas/mision_3_hachas.gd` |
| `EscenaCuestionario.tscn` (misión 3) | Responder 4 preguntas de reparación (ítems 1–4) | `recompensa_mision_3.tscn` | `scenes/cuestionarios/escena_cuestionario.gd`, `scenes/mision_3_hachas/mision_3_hachas.gd` |
| `recompensa_mision_3.tscn` | Botón **Continuar** (recompensa misión 3) | `mapa_topos.tscn` | `scenes/recompensa_mision_3/recompensa_mision_3.gd`, `scenes/recompensa_mision_3/recompensa_mision_3.tscn` |
| `mapa_topos.tscn` | Fin de partida (victoria) + botón **Ir al cuestionario** | `EscenaCuestionario.tscn` | `scenes/mision_4_payasos/mapa_topos.gd` |
| `EscenaCuestionario.tscn` (misión 4) | Responder 4 preguntas de reparación (ítems 5–8) + botón continuar narrativa | `resultado_final.tscn` | `scenes/cuestionarios/escena_cuestionario.gd`, `scenes/mision_4_payasos/mapa_topos.tscn` |
| `resultado_final.tscn` | Botón **Volver al menú principal** | `menu_principal.tscn` | `scenes/final/resultado_final.gd` |

## Checklist manual de validación (menú → cierre)

- [ ] Iniciar en menú principal y validar navegación a selección de género y personalización.
- [ ] Completar misión 1 y confirmar transición a cuestionario y llave 1.
- [ ] Completar misión 2 y confirmar apertura de puerta, cuestionario y llave 2.
- [ ] Completar misión 3 con 2 checkpoints y verificar pantalla de recompensa.
- [ ] Verificar que recompensa misión 3 continúe hacia `mapa_topos.tscn`.
- [ ] En misión de topos, validar flujos de derrota (reintento) y victoria (cuestionario).
- [ ] Confirmar narrativa post-cuestionario y botón de continuidad en cuestionarios.
- [ ] Llegar a resultado final y volver al menú principal con reinicio de estado.

## Tareas futuras sugeridas

1. Instrumentar analítica de transición por escena para detectar cortes de flujo.
2. Añadir pruebas automáticas de smoke flow para transiciones críticas.
3. Consolidar rutas legacy (`escena_topos`, `escena_12_*`) en constantes semánticas únicas.
