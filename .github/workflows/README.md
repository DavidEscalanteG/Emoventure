# CI de GitHub Actions (Godot)

Esta carpeta define una integración continua más robusta para **Emoventure**.

## Qué pruebas y validaciones se ejecutan

El flujo principal es `godot-ci.yml` y ejecuta 3 trabajos:

1. **workflow-lint**
   - **YAML lint** sobre `./.github/workflows` usando `ibiqlik/action-yamllint`.
   - **actionlint** para validar sintaxis y buenas prácticas de GitHub Actions mediante `reviewdog/action-actionlint@v1`.
   - **Por qué**: evita errores de configuración en CI (indentación, claves inválidas, expresiones mal formadas), que suelen romper pipelines aunque el código del juego esté bien.

2. **gdscript-check**
   - Instala Godot `4.5.1` en modo headless.
   - Recorre todos los archivos `*.gd` de código propio versionados, excluyendo `addons/**`:
     - `git ls-files '*.gd' ':(exclude)addons/**'`
   - Ejecuta verificación de sintaxis con:
     - `godot --headless --path . --check-only --script <archivo.gd>`
   - **Por qué**: detecta errores de sintaxis de GDScript de forma temprana en PRs, evitando falsos positivos que pueden aparecer en addons de terceros cuando se validan de forma aislada por archivo.

3. **smoke-test** (depende de los dos anteriores)
   - Ejecuta arranque headless del proyecto:
     - `godot --headless --path . --quit`
   - **Por qué**: valida que el proyecto pueda iniciarse en un entorno limpio de CI y que no existan fallos críticos de carga temprana.

## Mejoras de pipeline añadidas

- **`workflow_dispatch`**: permite lanzar CI manualmente desde GitHub.
- **`concurrency`**: cancela ejecuciones anteriores del mismo branch/PR para ahorrar tiempo y minutos.
- **Permisos mínimos** (`contents: read`): enfoque de seguridad por privilegio mínimo.

## Archivo de configuración de lint

- `./.github/workflows/.yamllint.yml`
  - Define reglas de estilo YAML usadas por `workflow-lint`.
  - Incluye una política de longitud de línea y normalización de booleanos.

## Cuándo ampliar esta CI

Recomendaciones para siguientes iteraciones:

- Agregar pruebas de gameplay automatizadas (si se incorporan escenas/test runners dedicados).
- Añadir job de export (build) por plataforma cuando el pipeline de release esté definido.
- Versionar una matriz de versiones Godot (ej. estable + próxima) si quieren detectar incompatibilidades temprano.
