# Guía musical para compositor/a de Emoventure

Este documento describe **qué piezas musicales se necesitan**, en qué momento del juego suenan y cómo deben nombrarse para que el sistema las detecte automáticamente.

## 1) Estructura esperada de archivos

Guardar todas las pistas en:

- `res://audios/musica/`

Nombre de archivos esperado por el juego:

- `menu_principal.ogg`
- `personalizacion.ogg`
- `mision_1.ogg`
- `mision_2.ogg`
- `mision_3.ogg`
- `mision_4.ogg`
- `transicion_llave.ogg`
- `cuestionario.ogg`
- `resultado_final.ogg`
- `dialogo_misterio.ogg`
- `dialogo_tension.ogg`
- `dialogo_calma.ogg`
- `dialogo_ternura.ogg`

> Formato recomendado: **OGG** en loop, estéreo, 44.1kHz o 48kHz.

---

## 2) Canciones por momento del juego

### Menú y preparación
- **Menú principal / selección de género** → `menu_principal.ogg`
  - Sensación: bienvenida, curiosidad, identidad del juego.
- **Personalización de personaje** → `personalizacion.ogg`
  - Sensación: ligera, creativa, positiva.

### Diálogos (ahora con ambiente musical)
- **Ambiente misterio** (`dialogo_misterio.ogg`)
  - Usado en: `intro_dialogo_1`, `intro_mision_2`
  - Sensación: exploración emocional, incertidumbre suave.
- **Ambiente tensión** (`dialogo_tension.ogg`)
  - Usado en: `intro_dialogo_2`, `intro_dialogo_3`, `intro_dialogo_4`
  - Sensación: inquietud, reto inminente, gravedad.
- **Ambiente ternura** (`dialogo_ternura.ogg`)
  - Usado en: `intro_dialogo_5`
  - Sensación: vínculo, alivio, cercanía.
- **Ambiente calma** (`dialogo_calma.ogg`)
  - Usado en: `intro_mision_4`
  - Sensación: respiración previa al juego, contención emocional.

### Gameplay y progreso
- **Misión 1 (recolección de emociones)** → `mision_1.ogg`
- **Misión 2 (memorias)** → `mision_2.ogg`
- **Misión 3 (hachas)** → `mision_3.ogg`
- **Misión 4 (topos/payasos)** → `mision_4.ogg`
- **Cuestionarios** → `cuestionario.ogg`
  - Puede derivar de la música de misión, pero más neutral para lectura.

### Transiciones y cierre
- **Transición post misión (llaves/recompensas)** → `transicion_llave.ogg`
- **Resultado final** → `resultado_final.ogg`
  - Sensación: cierre emocional, conclusión del viaje.

---

## 3) Recomendaciones creativas

- Mantener una **paleta armónica común** para que todo suene parte del mismo universo.
- Usar capas/variantes (pads, percusión suave, texturas) para reutilizar motivos sin fatigar.
- Evitar rangos muy agresivos de volumen para no competir con diálogos o SFX.
- Priorizar loops limpios (sin clicks al reiniciar).

---

## 4) Integración técnica

La lógica de reproducción está en:

- `src/autoload/music_manager.gd`

Si una pista no existe, el juego continúa y mostrará un warning en consola indicando el archivo faltante.
