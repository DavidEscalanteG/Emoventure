# Guía musical para compositor/a de Emoventure

Esta guía organiza la dirección musical **por bloque del juego** para facilitar producción, iteración e integración en Godot.

## 1) Convenciones generales de entrega

- Carpeta de destino en proyecto: `res://audios/musica/`
- Formato actual integrado en el proyecto: **.mp3** estéreo.
- Enfoque de mezcla global:
  - Pico recomendado: entre **-6 dBFS y -3 dBFS** (headroom para voz/SFX).
  - Objetivo orientativo de loudness integrado para gameplay: **-18 a -16 LUFS**.
  - Evitar enmascaramiento de voz en rango medio (aprox. 1–4 kHz).

---

## 2) Bloques musicales por escena

### Menú / selección / personalización
- `menu_principal` (menú principal y selección inicial)
- `personalizacion` (creación/personalización de personaje)

### Intros narrativas
- `intro_dialogo_1` → `dialogo_misterio`
- `intro_dialogo_2` → `dialogo_tension`
- `intro_dialogo_3` → `dialogo_tension`
- `intro_dialogo_4` → `dialogo_tension`
- `intro_dialogo_5` → `dialogo_ternura`
- `intro_mision_2` → `dialogo_misterio`
- `intro_mision_4` → `dialogo_calma`

### Misiones
- `mision_1` (recolección de emociones)
- `mision_2` (memorias)
- `mision_3` (hachas)
- `mision_4` (topos/payasos)

### Cuestionarios
- `cuestionario` (cuestionarios de todas las misiones)

### Transiciones / recompensas
- `transicion_llave` (post misión, llave/recompensa/progreso)

### Resultado final
- `resultado_final` (pantalla/estado de cierre del viaje)

---

## 3) Tabla de correspondencia técnica

| clave_musical | ruta_archivo | escenas consumidoras |
|---|---|---|
| `menu_principal` | `res://audios/musica/menu_principal.mp3` | `res://scenes/menu_principal/menu_principal.tscn`, `res://scenes/intro_seleccion_genero/intro_seleccion_genero.tscn` |
| `personalizacion` | `res://audios/musica/personalizacion.mp3` | `res://scenes/personalizacion/Personalizacion.tscn` |
| `dialogo_misterio` (`misterio`) | `res://audios/musica/dialogo_misterio.mp3` | `res://scenes/intro_dialogo_1/intro_dialogo_1.tscn`, `res://scenes/intro_mision_2/intro_mision_2.tscn` |
| `dialogo_tension` (`tension`) | `res://audios/musica/dialogo_tension.mp3` | `res://scenes/intro_dialogo_2/intro_dialogo_2.tscn`, `res://scenes/intro_dialogo_3/intro_dialogo_3.tscn`, `res://scenes/intro_dialogo_4/intro_dialogo_4.tscn` |
| `dialogo_ternura` (`ternura`) | `res://audios/musica/dialogo_ternura.mp3` | `res://scenes/intro_dialogo_5/intro_dialogo_5.tscn` |
| `dialogo_calma` (`calma`) | `res://audios/musica/dialogo_calma.mp3` | `res://scenes/intro_mision_4/intro_mision_4.tscn` |
| `mision_1` | `res://audios/musica/mision_1.mp3` | `res://scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn` |
| `mision_2` | `res://audios/musica/mision_2.mp3` | `res://scenes/mision_2_memorias/mision_2_memorias.tscn` |
| `mision_3` | `res://audios/musica/mision_3.mp3` | `res://scenes/mision_3_hachas/mision_3_hachas.tscn` |
| `mision_4` | `res://audios/musica/mision_4.mp3` | `res://scenes/mision_4_payasos/mapa_topos.tscn` |
| `cuestionario` | `res://audios/musica/cuestionario.mp3` | `res://scenes/cuestionarios/EscenaCuestionario.tscn` |
| `transicion_llave` | `res://audios/musica/transicion_llave.mp3` | `res://scenes/transicion_post_mision_1/transicion_post_mision_1.tscn`, `res://scenes/transicion_post_mision_2/transicion_post_mision_2.tscn`, `res://scenes/recompensa_mision_3/recompensa_mision_3.tscn` |
| `resultado_final` | `res://audios/musica/resultado_final.mp3` | `res://scenes/final/resultado_final.tscn` |

---

## 4) Checklist de QA musical (previo a integración)

- [ ] **Loop limpio:** sin clics, pops ni saltos de fase al reinicio.
- [ ] **Loudness/LUFS objetivo:** dentro de rango definido para gameplay.
- [ ] **Headroom correcto:** picos máximos en rango recomendado para convivencia con voz/SFX.
- [ ] **Mono-compatibilidad:** sin cancelaciones críticas al colapsar a mono.
- [ ] **Balance espectral:** graves controlados y medios despejados para inteligibilidad.
- [ ] **Validación de ruta en proyecto:** archivo presente en `res://audios/musica/` con nombre exacto esperado.
- [ ] **Prueba en escena consumidora:** verificación de reproducción, loop y volumen relativo dentro del juego.

---

## 5) Integración técnica

La lógica de reproducción está centralizada en:

- `src/autoload/music_manager.gd`

Si una pista no existe, el juego continúa y se mostrará un warning en consola indicando el archivo faltante.
