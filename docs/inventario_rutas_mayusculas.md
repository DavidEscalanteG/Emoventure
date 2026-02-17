# Inventario de rutas con mayúsculas

**Última auditoría:** 2026-02-16  
**Criterio objetivo aplicado:** búsqueda en todo el repositorio de archivos `*.gd` y `*.tscn` cuyo **nombre de archivo** (basename) contiene al menos una letra mayúscula (`[A-Z]`).

Comando de referencia usado para auditar:

```bash
python - <<'PY'
import os
for dp, _, files in os.walk('.'):
	for f in files:
		if f.endswith(('.gd', '.tscn')) and any(c.isupper() for c in f):
			print(os.path.relpath(os.path.join(dp, f), '.'))
PY
```

## Inventario detectado actualmente

Resultado actual de la auditoría (12 archivos):

- `assets/assets_escena_3/UI/EmocionesUI.tscn`
- `assets/assets_escena_3/UI/NivelCompletadoUI.tscn`
- `assets/assets_escena_3/UI/VidasUI.tscn`
- `assets/enemigos/serpiente/Enemigo.tscn`
- `scenes/Topos.tscn`
- `scenes/cuestionarios/EscenaCuestionario.tscn`
- `scenes/mision_3_hachas/HachaObstaculo.tscn`
- `scenes/mision_4_payasos/Topo.tscn`
- `scenes/personalizacion/JugadorBase.tscn`
- `scenes/personalizacion/Personalizacion.tscn`
- `scenes/personalizacion/Personalizador.gd`
- `src/autoload/Logs.gd`

## Decisiones de normalización pendientes

Pendiente acordar y ejecutar en PRs de normalización:

1. **Alcance de la regla:** confirmar si la convención de minúsculas aplica solo a scripts (`.gd`) o también a escenas (`.tscn`).
2. **Rutas públicas/referencias:** validar impacto en `preload/load`, `class_name`, export variables y referencias de escenas antes de renombrar.
3. **Prioridad de migración:**
   - Alta prioridad: `scenes/personalizacion/Personalizador.gd` (script con mayúsculas).
   - Nota: `src/autoload/Logs.gd` se mantiene con mayúscula por compatibilidad de nombre público del singleton `Logs` y ya está referenciado con el casing exacto en `project.godot` y `docs/arquitectura.md`.
   - Prioridad media: escenas con mayúsculas bajo `scenes/` y `assets/`.
4. **Estrategia de ejecución:** decidir si se hace en un único PR atómico o por lotes (por carpeta/sistema) para reducir riesgo de regresiones.

## Resultado esperado después (criterio de salida)

Para que este documento no quede obsoleto en el siguiente PR de normalización, el estado objetivo debe ser verificable con el mismo criterio:

- **Si la regla definida es “minúsculas para `.gd` y `.tscn`”:** la auditoría debe devolver **0 resultados**.
- **Si la regla definida es “minúsculas solo para `.gd`”:** la auditoría filtrada a `*.gd` debe devolver **0 resultados** y la sección de excepciones para `.tscn` debe quedar explícita y justificada.

Cuando se cierre una decisión, actualizar este documento en el mismo PR con:

- fecha de auditoría,
- comando usado,
- resultado numérico,
- y excepciones aprobadas (si existen).
