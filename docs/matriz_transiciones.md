# Matriz de transiciones de escenas

Fuente operativa para validar flujo real del proyecto.

| escena_origen | trigger | destino | archivo_fuente |
|---|---|---|---|
| `menu_principal.tscn` | Botón **Comenzar** | `intro_seleccion_genero.tscn` | `scenes/menu_principal/comenzar.gd` |
| `menu_principal.tscn` | Botón **Configuración** | `configuracion.tscn` | `scenes/menu_principal/configuracion.gd` |
| `menu_principal.tscn` | Botón **Créditos** | `creditos.tscn` | `scenes/menu_principal/creditos.gd` |
| `configuracion.tscn` | Botón **Volver** | `menu_principal.tscn` | `scenes/configuracion/configuracion.gd` |
| `creditos.tscn` | Botón **Volver** | `menu_principal.tscn` | `scenes/creditos/creditos.gd` |
| `intro_seleccion_genero.tscn` | Botón continuar | `Personalizacion.tscn` | `scenes/intro_seleccion_genero/intro_seleccion_genero.gd` |
| `Personalizacion.tscn` | Botón **Comenzar** | `intro_dialogo_1.tscn` | `scenes/personalizacion/Personalizador.gd` |
| `intro_dialogo_1.tscn` | `dialogo_finalizado` | `intro_dialogo_2.tscn` | `scenes/intro_dialogo_1/intro_dialogo_1.gd` |
| `intro_dialogo_2.tscn` | `dialogo_finalizado` | `mapa_1..mapa_5` (rotación aleatoria) | `scenes/intro_dialogo_2/intro_dialogo_2.gd`, `src/autoload/game_manager.gd` |
| `mision_1_recoleccion.tscn` (cualquier mapa) | Completar nivel | `EscenaCuestionario.tscn` (M1) | `scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.gd`, `src/ui/nivel_completado_ui.gd` |
| `EscenaCuestionario.tscn` (M1) | Continuar (`escena_siguiente`) | `transicion_post_mision_1.tscn` | `scenes/cuestionarios/escena_cuestionario.gd`, `scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn` |
| `transicion_post_mision_1.tscn` | Botón continuar | `intro_dialogo_3.tscn` | `scenes/transicion_post_mision_1/primera_llave.gd` |
| `intro_dialogo_3.tscn` | `dialogo_finalizado` | `intro_dialogo_4.tscn` | `scenes/intro_dialogo_3/intro_dialogo_3.gd` |
| `intro_dialogo_4.tscn` | `dialogo_finalizado` | `intro_dialogo_5.tscn` | `scenes/intro_dialogo_4/intro_dialogo_4.gd` |
| `intro_dialogo_5.tscn` | `dialogo_finalizado` | `intro_mision_2.tscn` | `scenes/intro_dialogo_5/intro_dialogo_5.gd` |
| `intro_mision_2.tscn` | `dialogo_finalizado` | `mision_2_memorias.tscn` | `scenes/intro_mision_2/intro_mision_2.gd` |
| `mision_2_memorias.tscn` | Puerta habilitada | `EscenaCuestionario.tscn` (M2) | `scenes/mision_2_memorias/puerta_cuestionario.gd` |
| `EscenaCuestionario.tscn` (M2) | Continuar (`escena_siguiente`) | `transicion_post_mision_2.tscn` | `scenes/cuestionarios/escena_cuestionario.gd`, `scenes/mision_2_memorias/mision_2_memorias.tscn` |
| `transicion_post_mision_2.tscn` | Botón continuar | `mision_3_hachas.tscn` | `scenes/transicion_post_mision_2/segunda_llave.gd` |
| `mision_3_hachas.tscn` | Salida + 2 checkpoints | `EscenaCuestionario.tscn` (M3) | `scenes/mision_3_hachas/mision_3_hachas.gd` |
| `EscenaCuestionario.tscn` (M3) | Continuar (`escena_siguiente`) | `recompensa_mision_3.tscn` | `scenes/cuestionarios/escena_cuestionario.gd`, `scenes/mision_3_hachas/mision_3_hachas.gd` |
| `recompensa_mision_3.tscn` | Botón continuar | `mapa_topos.tscn` | `scenes/recompensa_mision_3/recompensa_mision_3.gd`, `scenes/recompensa_mision_3/recompensa_mision_3.tscn` |
| `intro_mision_4.tscn` | `dialogo_finalizado` | `mapa_topos.tscn` | `scenes/intro_mision_4/intro_mision_4.gd` |
| `mapa_topos.tscn` | Victoria + continuar | `EscenaCuestionario.tscn` (M4) | `scenes/mision_4_payasos/mapa_topos.gd`, `scenes/mision_4_payasos/mapa_topos.tscn` |
| `EscenaCuestionario.tscn` (M4) | Continuar (`escena_siguiente`) | `resultado_final.tscn` | `scenes/cuestionarios/escena_cuestionario.gd`, `scenes/mision_4_payasos/mapa_topos.gd` |
| `resultado_final.tscn` | Botón continuar | `mapa_rejugabilidad.tscn` | `scenes/final/resultado_final.gd` |
| `mapa_rejugabilidad.tscn` | Botón Minijuego1 | `mapa_1..mapa_5` (rotación aleatoria) | `scenes/rejugabilidad/mapa_rejugabilidad.gd`, `src/autoload/game_manager.gd` |
| `mapa_rejugabilidad.tscn` | Botón Minijuego2 | `mision_2_memorias.tscn` | `scenes/rejugabilidad/mapa_rejugabilidad.gd` |
| `mapa_rejugabilidad.tscn` | Botón Minijuego3 | `mision_3_hachas.tscn` | `scenes/rejugabilidad/mapa_rejugabilidad.gd` |
| `mapa_rejugabilidad.tscn` | Botón Minijuego4 | `mapa_topos.tscn` | `scenes/rejugabilidad/mapa_rejugabilidad.gd` |
| `mapa_rejugabilidad.tscn` | Botón volver resultados | `resultado_final.tscn` | `scenes/rejugabilidad/mapa_rejugabilidad.gd` |

## Checklist manual mínimo

- [ ] Menú: validar Comenzar, Configuración, Créditos.
- [ ] Flujo principal completo hasta `resultado_final.tscn`.
- [ ] Verificar que el cierre real envía a `mapa_rejugabilidad.tscn`.
- [ ] Desde rejugabilidad, validar acceso a minijuegos 1–4.
- [ ] En rejugabilidad, confirmar retorno a resultados.
