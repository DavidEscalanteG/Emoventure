# CONTRIBUTING

## Objetivo
Mantener una base de código consistente, tipada y desacoplada para Godot 4.5.1.

## Estándares de estilo
- `class_name` en PascalCase para clases relevantes.
- Nombre de archivo `.gd` coherente con la responsabilidad del script.
- Tipado explícito en variables, constantes, parámetros y retornos.
- No usar `var` sin tipo.
- Constantes en MAYÚSCULAS con guion bajo.

## Arquitectura y responsabilidades
- `core/managers`: estado global/autoload.
- `core/services`: lógica transversal reusable.
- `scripts/ui`: solo lógica de interfaz.
- `scripts/components`: lógica reusable de gameplay.
- Evitar acoplamiento fuerte con rutas hardcodeadas entre escenas.

## Señales y flujo
- Usar señales para comunicación entre nodos de distinta capa.
- Evitar llamadas directas a nodos lejanos (`../../..`).
- Preferir `GameFlowManager` para transiciones.

## Calidad
- Eliminar código comentado o variables no usadas.
- Verificar warnings de parser en Godot.
- Documentar decisiones importantes en `docs/`.

## Checklist de PR
- [ ] Escena/script ubicados en la carpeta correcta.
- [ ] Tipado explícito aplicado.
- [ ] Sin rutas rotas (`change_scene_to_file`, `preload`, `load`).
- [ ] Documentación actualizada.
