# Convención de nombres para escenas narrativas y de transición

## Regla general

Usar `snake_case` con prefijo semántico y orden lógico:

- `intro_dialogo_<n>`: escenas narrativas previas o intermedias.
- `intro_mision_<n>`: introducción inmediata a una misión jugable.
- `mision_<n>_<tema>`: escena jugable principal de misión.
- `transicion_post_mision_<n>`: pantallas de llave/recompensa posteriores a misión.
- `recompensa_mision_<n>`: escena de recompensa explícita de misión.

## Mapeo aplicado en este repositorio

- `escena_1` → `intro_dialogo_1`
- `escena_2` → `intro_dialogo_2`
- `escena_3` → `mision_1_recoleccion`
- `escena_4_llave` → `transicion_post_mision_1`
- `escena_5` → `intro_dialogo_3`
- `escena_6` → `intro_dialogo_4`
- `escena_7` → `intro_dialogo_5`
- `escena_8` → `intro_mision_2`
- `escena_9` → `mision_2_memorias`
- `escena_10_llave` → `transicion_post_mision_2`
- `escena_11_mision_3` → `mision_3_hachas`
- `escena_12_recompensa_m3` → `recompensa_mision_3`
- `escena_13` → `intro_mision_4`
- `escena_topos` → `mision_4_payasos` 
- `escena_seleccion_genero` → `intro_seleccion_genero`
