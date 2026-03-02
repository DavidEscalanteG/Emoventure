# Inventario de rutas con mayúsculas

**Última auditoría:** 2026-02-26
**Criterio objetivo aplicado:** búsqueda en todo el repositorio de archivos `*.gd` y `*.tscn` cuyo nombre de archivo contiene al menos una letra mayúscula (`[A-Z]`).

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

Resultado actual de la auditoría (**14 archivos**):

- `assets/assets_escena_3/UI/EmocionesUI.tscn`
- `assets/assets_escena_3/UI/NivelCompletadoUI.tscn`
- `assets/assets_escena_3/UI/VidasUI.tscn`
- `assets/enemigos/serpiente/Enemigo.tscn`
- `scenes/Topos.tscn`
- `scenes/cuestionarios/EscenaCuestionario.tscn`
- `scenes/mision_1_recoleccion/tutorial/Minijuego1_Tutorial.tscn`
- `scenes/mision_2_memorias/tutorial/Minijuego2_Tutorial.tscn`
- `scenes/mision_3_hachas/HachaObstaculo.tscn`
- `scenes/mision_4_payasos/Topo.tscn`
- `scenes/personalizacion/JugadorBase.tscn`
- `scenes/personalizacion/Personalizacion.tscn`
- `scenes/personalizacion/Personalizador.gd`
- `src/autoload/Logs.gd`

## Decisiones de normalización pendientes

1. Confirmar si la regla de minúsculas aplica a ambos tipos (`.gd` y `.tscn`) o solo scripts.
2. Validar impacto de renombres en referencias de escenas/scripts (`load/preload`, exports, rutas en `.tscn`).
3. Priorizar scripts con mayúsculas:
   - `scenes/personalizacion/Personalizador.gd`
   - `src/autoload/Logs.gd` (si se decide conservar, documentar excepción por compatibilidad del singleton).
4. Ejecutar migración por lotes pequeños para reducir regresiones de rutas.
