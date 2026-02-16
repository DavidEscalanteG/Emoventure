# Guía musical para compositor/a de Emoventure

Esta guía organiza la dirección musical **por bloque del juego** e incluye prompts listos para IA musical con parámetros técnicos consistentes para facilitar producción, iteración e integración en Godot.

## 1) Convenciones generales de entrega

- Carpeta de destino en proyecto: `res://audios/musica/`
- Formato recomendado: **.ogg** estéreo, 44.1 kHz o 48 kHz, loopable.
- Enfoque de mezcla global:
  - Pico recomendado: entre **-6 dBFS y -3 dBFS** (headroom para voz/SFX).
  - Objetivo orientativo de loudness integrado para gameplay: **-18 a -16 LUFS**.
  - Evitar enmascaramiento de voz en rango medio (aprox. 1–4 kHz).

---

## 2) Bloque: Menú / selección / personalización

### Escenas objetivo
- `menu_principal` (menú principal y selección inicial)
- `personalizacion` (creación/personalización de personaje)

### Prompt IA musical (base)
- **Objetivo emocional y narrativa del momento:** dar bienvenida, despertar curiosidad y transmitir identidad positiva del juego; sensación de inicio de viaje emocional seguro.
- **BPM/tempo range, compás, tonalidad sugerida:** 88–108 BPM, 4/4, tonalidad mayor o modo mixolidio/lidio suave (ej. C, D, G).
- **Instrumentación permitida/prohibida:**
  - Permitida: pads cálidos, piano suave, bajo redondo, percusión ligera orgánica, texturas brillantes discretas.
  - Prohibida: distorsiones agresivas, metales estridentes, percusión dura tipo trailer, subgraves dominantes.
- **Nivel de intensidad (0–100), densidad rítmica, dinámica:** intensidad 35/100, densidad baja-media, dinámica estable con microvariaciones.
- **Estructura del loop (duración objetivo, intro mínima, seamless loop):** 60–90 s, intro máxima 2 s, cierre diseñado para loop perfecto sin clics ni colas abruptas.
- **Referencias estilísticas abstractas (sin infracción de obras concretas):** ambient electrónico orgánico + pop lúdico minimal + scoring de aventura amable.
- **Restricciones de mezcla (headroom, no competir con voz/SFX):** mantener picos <= -3 dBFS, espacio en medios para UI/voz, transitorios suaves para no tapar SFX de interfaz.

### Variantes adaptativas por escena
- **Normal:** textura luminosa estable, pulso suave.
- **Tensión alta:** +10 a +15 de intensidad, capas rítmicas sutiles adicionales, armonía con mayor suspensión.
- **Resolución suave:** reducir percusión, mantener motivo melódico principal con mayor aire y release largo.

---

## 3) Bloque: Cada intro narrativa

### Escenas objetivo
- `intro_dialogo_1` → atmósfera misterio suave
- `intro_dialogo_2` → tensión emocional
- `intro_dialogo_3` → tensión/reto
- `intro_dialogo_4` → tensión sostenida
- `intro_dialogo_5` → ternura y vínculo
- `intro_mision_2` → exploración emocional (misterio)
- `intro_mision_4` → calma previa a misión

> Nota de implementación actual: estas escenas consumen ambientes tipo `dialogo_misterio.ogg`, `dialogo_tension.ogg`, `dialogo_ternura.ogg`, `dialogo_calma.ogg`. Se recomienda mantener esa familia tímbrica coherente.

### Prompt IA musical (base)
- **Objetivo emocional y narrativa del momento:** reforzar el contenido narrativo sin distraer de texto/voz; sostener emoción específica por intro (misterio, tensión, ternura o calma).
- **BPM/tempo range, compás, tonalidad sugerida:** 60–90 BPM, 4/4 o 3/4 según escena, tonalidades modales (dórico/eólico) y cambios sutiles para matiz emocional.
- **Instrumentación permitida/prohibida:**
  - Permitida: drones suaves, piano felt, cuerdas ligeras, marimba/bells discretos, texturas aireadas.
  - Prohibida: baterías invasivas, leads muy presentes, efectos jump-scare, risers exagerados.
- **Nivel de intensidad (0–100), densidad rítmica, dinámica:** intensidad 20–55/100 según intro, densidad baja, dinámica muy controlada para lectura.
- **Estructura del loop (duración objetivo, intro mínima, seamless loop):** 45–75 s, intro de 1–2 s máximo, loop continuo con cola musical reciclada al inicio.
- **Referencias estilísticas abstractas (sin infracción de obras concretas):** underscore cinematográfico íntimo, ambient emocional minimalista, texturas narrativas contemplativas.
- **Restricciones de mezcla (headroom, no competir con voz/SFX):** priorizar inteligibilidad de diálogo; recortar energía en 2–4 kHz si compite con voz; picos <= -4 dBFS.

### Variantes adaptativas por escena
- **Normal:** motivo armónico base y textura principal de fondo.
- **Tensión alta:** disonancias suaves, pulsos percusivos ligeros, +10 intensidad sin aumentar demasiado volumen.
- **Resolución suave:** resolver intervalos tensos, caída de densidad, timbres cálidos prolongados.

---

## 4) Bloque: Misión 1–4

### Escenas objetivo
- `mision_1` (recolección de emociones)
- `mision_2` (memorias)
- `mision_3` (hachas)
- `mision_4` (topos/payasos)

### Prompt IA musical (base)
- **Objetivo emocional y narrativa del momento:** acompañar gameplay activo manteniendo foco y motivación; reflejar progresión y reto sin fatigar.
- **BPM/tempo range, compás, tonalidad sugerida:** 100–128 BPM, 4/4, tonalidades menores luminosas o modos híbridos para energía con calidez.
- **Instrumentación permitida/prohibida:**
  - Permitida: percusión híbrida suave, bajo definido no invasivo, sintetizadores rítmicos limpios, elementos melódicos cortos.
  - Prohibida: kicks excesivos, capas saturadas en graves, leads estridentes continuos.
- **Nivel de intensidad (0–100), densidad rítmica, dinámica:** intensidad 55–75/100, densidad media, dinámica moderada con picos de secciones.
- **Estructura del loop (duración objetivo, intro mínima, seamless loop):** 75–120 s, intro <2 s, loop con bloques A/B que regresen sin corte perceptible.
- **Referencias estilísticas abstractas (sin infracción de obras concretas):** electro-orquestal ligero para juego casual, groove cinemático optimista, aventura arcade emocional.
- **Restricciones de mezcla (headroom, no competir con voz/SFX):** reservar espacio para efectos de interacción; controlar graves <80 Hz; picos <= -3 dBFS.

### Variantes adaptativas por escena
- **Normal:** groove principal equilibrado para sesión prolongada.
- **Tensión alta:** añadir capa rítmica/ostinato y acentos armónicos; +10–20 intensidad.
- **Resolución suave:** retirar elementos percusivos secundarios y cerrar con textura más abierta.

---

## 5) Bloque: Cuestionarios por misión

### Escenas objetivo
- `cuestionario` (aplicable a cuestionarios posteriores a cada misión)

### Prompt IA musical (base)
- **Objetivo emocional y narrativa del momento:** sostener concentración y calma cognitiva tras la misión; evitar presión excesiva durante lectura y respuesta.
- **BPM/tempo range, compás, tonalidad sugerida:** 72–96 BPM, 4/4, tonalidades estables (mayor suave o dórico ligero).
- **Instrumentación permitida/prohibida:**
  - Permitida: pads neutros, arpegios discretos, percusión mínima, piano blando.
  - Prohibida: melodías muy pegajosas, percusión marcada constante, FX sorpresivos.
- **Nivel de intensidad (0–100), densidad rítmica, dinámica:** intensidad 30–45/100, densidad baja-media, dinámica plana-controlada.
- **Estructura del loop (duración objetivo, intro mínima, seamless loop):** 60–90 s, intro <= 1.5 s, loop largo para no evidenciar repetición.
- **Referencias estilísticas abstractas (sin infracción de obras concretas):** lo-fi limpio instrumental, ambient cognitivo suave, minimalismo melódico funcional.
- **Restricciones de mezcla (headroom, no competir con voz/SFX):** evitar masking de UI/voz de guía; picos <= -4 dBFS; medios controlados.

### Variantes adaptativas por escena
- **Normal:** base neutra enfocada en legibilidad.
- **Tensión alta:** incremento muy leve de pulso para urgencia temporal sin estrés.
- **Resolución suave:** reducción de elementos rítmicos y mayor pad armónico de descanso.

---

## 6) Bloque: Transiciones / recompensas

### Escenas objetivo
- `transicion_llave` (post misión, llave/recompensa/progreso)

### Prompt IA musical (base)
- **Objetivo emocional y narrativa del momento:** comunicar logro, cierre breve y expectativa positiva del siguiente paso.
- **BPM/tempo range, compás, tonalidad sugerida:** 96–120 BPM, 4/4, mayor brillante o dominante resuelta.
- **Instrumentación permitida/prohibida:**
  - Permitida: stabs armónicos suaves, percusión ligera de celebración, capas brillantes cortas.
  - Prohibida: fanfarrias exageradas, impactos demasiado largos, subgraves agresivos.
- **Nivel de intensidad (0–100), densidad rítmica, dinámica:** intensidad 60/100 con release rápido, densidad media-baja, dinámica con énfasis inicial.
- **Estructura del loop (duración objetivo, intro mínima, seamless loop):** 20–45 s, intro inmediata, si se usa en loop mantener segmento corto cíclico y limpio.
- **Referencias estilísticas abstractas (sin infracción de obras concretas):** UI reward music minimalista, aventura positiva, señal sonora de progreso.
- **Restricciones de mezcla (headroom, no competir con voz/SFX):** dejar espacio a SFX de recompensa; picos <= -3 dBFS; evitar exceso en agudos.

### Variantes adaptativas por escena
- **Normal:** motivo celebratorio corto y claro.
- **Tensión alta:** más drive rítmico y suspense de paso siguiente.
- **Resolución suave:** timbre cálido, menos transiente, sensación de descanso.

---

## 7) Bloque: Resultado final

### Escenas objetivo
- `resultado_final` (pantalla/estado de cierre del viaje)

### Prompt IA musical (base)
- **Objetivo emocional y narrativa del momento:** cerrar arco emocional con sensación de logro, reflexión y continuidad esperanzadora.
- **BPM/tempo range, compás, tonalidad sugerida:** 70–96 BPM, 4/4 o 6/8, tonalidad mayor cálida o menor-resuelta.
- **Instrumentación permitida/prohibida:**
  - Permitida: piano/cuerdas suaves, pads envolventes, percusión ligera opcional, textura aérea final.
  - Prohibida: percusión agresiva, cambios bruscos de energía, capas demasiado densas.
- **Nivel de intensidad (0–100), densidad rítmica, dinámica:** intensidad 40–60/100, densidad media-baja, dinámica expresiva pero estable.
- **Estructura del loop (duración objetivo, intro mínima, seamless loop):** 75–120 s, intro de 2–4 s aceptable, loop o versión extendida según duración de pantalla.
- **Referencias estilísticas abstractas (sin infracción de obras concretas):** cierre cinematográfico íntimo, ambient esperanzador, epílogo emocional positivo.
- **Restricciones de mezcla (headroom, no competir con voz/SFX):** picos <= -3 dBFS, control de medios-altos para texto final legible, no saturar reverbs.

### Variantes adaptativas por escena
- **Normal:** cierre completo equilibrado.
- **Tensión alta:** enfatizar notas de expectativa y menor resolución armónica inicial.
- **Resolución suave:** versión más cálida y contemplativa, con menos percusión y mayor cola armónica.

---

## 8) Tabla de correspondencia técnica

| clave_musical | ruta_archivo | escenas consumidoras |
|---|---|---|
| `menu_principal` | `res://audios/musica/menu_principal.ogg` | menú principal, selección inicial |
| `personalizacion` | `res://audios/musica/personalizacion.ogg` | personalización de personaje |
| `dialogo_misterio` | `res://audios/musica/dialogo_misterio.ogg` | `intro_dialogo_1`, `intro_mision_2` |
| `dialogo_tension` | `res://audios/musica/dialogo_tension.ogg` | `intro_dialogo_2`, `intro_dialogo_3`, `intro_dialogo_4` |
| `dialogo_ternura` | `res://audios/musica/dialogo_ternura.ogg` | `intro_dialogo_5` |
| `dialogo_calma` | `res://audios/musica/dialogo_calma.ogg` | `intro_mision_4` |
| `mision_1` | `res://audios/musica/mision_1.ogg` | misión 1 |
| `mision_2` | `res://audios/musica/mision_2.ogg` | misión 2 |
| `mision_3` | `res://audios/musica/mision_3.ogg` | misión 3 |
| `mision_4` | `res://audios/musica/mision_4.ogg` | misión 4 |
| `cuestionario` | `res://audios/musica/cuestionario.ogg` | cuestionarios de todas las misiones |
| `transicion_llave` | `res://audios/musica/transicion_llave.ogg` | transición post misión / recompensa |
| `resultado_final` | `res://audios/musica/resultado_final.ogg` | pantalla de resultado final |

---

## 9) Checklist de QA musical (previo a integración)

- [ ] **Loop limpio:** sin clics, pops ni saltos de fase al reinicio.
- [ ] **Loudness/LUFS objetivo:** dentro de rango definido para gameplay.
- [ ] **Headroom correcto:** picos máximos en rango recomendado para convivencia con voz/SFX.
- [ ] **Mono-compatibilidad:** sin cancelaciones críticas al colapsar a mono.
- [ ] **Balance espectral:** graves controlados y medios despejados para inteligibilidad.
- [ ] **Validación de ruta en proyecto:** archivo presente en `res://audios/musica/` con nombre exacto esperado.
- [ ] **Prueba en escena consumidora:** verificación de reproducción, loop y volumen relativo dentro del juego.

---

## 10) Integración técnica

La lógica de reproducción está centralizada en:

- `src/autoload/music_manager.gd`

Si una pista no existe, el juego continúa y se mostrará un warning en consola indicando el archivo faltante.
