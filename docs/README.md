# Emoventure — Documentación Técnica

## Descripción del proyecto
Emoventure es un videojuego educativo en Godot 4.5.1 centrado en inteligencia emocional. El juego se organiza por un flujo principal de navegación y un conjunto de minijuegos desacoplados para facilitar mantenimiento y escalabilidad.

## Arquitectura general
- **Autoloads en `core/managers/`**: estado global y orquestación (`GameManager`, `GameFlowManager`, `DataManager`, `Logs`, etc.).
- **Servicios en `core/services/`**: funcionalidades transversales separadas por dominio (por ejemplo, actores de diálogo).
- **Escenas en `scenes/`**: agrupadas por intención funcional (`main_menu`, `map`, `results`, `minigames`, `tutorials`).
- **Scripts en `scripts/`**: componentes reutilizables, UI, utilidades y managers no globales.
- **Datos en `data/`**: recursos JSON/Config para preguntas, configuración y tablas futuras.

## Estructura de carpetas
```text
res://
├── addons/
├── core/
│   ├── managers/
│   ├── services/
│   └── state/
├── scenes/
│   ├── main_menu/
│   ├── map/
│   ├── results/
│   ├── minigames/
│   │   ├── minigame_1/
│   │   ├── minigame_2/
│   │   ├── minigame_3/
│   │   └── minigame_4/
│   └── tutorials/
├── scripts/
│   ├── managers/
│   ├── components/
│   ├── ui/
│   └── utilities/
├── assets/
├── data/
└── docs/
```

## Flujo del juego
`MainMenu → Minijuego/Tutorial → Results → Map(Rejugabilidad) → Replay`

El flujo está centralizado con `GameFlowManager` para evitar dependencias directas entre escenas.

## Managers clave
- `GameManager`: puntaje y rotación de mapas.
- `PlayerDataManager` (`DatosJugador`): estado temporal de sesión/jugador.
- `DataManager`: acceso centralizado a datos estáticos.
- `Logs`: logging estructurado por contexto y nivel.

## Convenciones de código
- Clases en `PascalCase`.
- Variables, señales y funciones en `snake_case`.
- Constantes en `UPPER_SNAKE_CASE`.
- Tipado explícito obligatorio.
- Evitar lógica de juego dentro de scripts de UI.

## Cómo añadir un nuevo minijuego
1. Crear `scenes/minigames/minigame_X/`.
2. Añadir su escena raíz y scripts en `scripts/components/` o `scripts/ui/` según responsabilidad.
3. Registrar sus rutas de transición en `GameFlowManager`.
4. Si usa datos externos, agregar archivo en `data/` y consumirlo desde `DataManager`.
5. Documentar entradas/salidas del minijuego en `docs/`.

## Cómo añadir un nuevo tutorial
1. Crear carpeta en `scenes/tutorials/`.
2. Reusar componentes existentes de UI y señales.
3. Definir escena de salida y conexión con `GameFlowManager`.
4. Agregar notas de diseño en `docs/flujo_misiones_emoventure.md`.
