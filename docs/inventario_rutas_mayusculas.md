# Inventario de rutas con mayúsculas

## Inventario inicial en rutas

- `src/autoload/Logs.gd`
- `src/autoload/DialogueActors.gd`
- `src/autoload/DatosJugador.gd`
- `src/autoload/GameManager.gd`
- `src/autoload/estado/MascotaSeleccion.gd`
- `src/autoload/estado/AparienciaJugador.gd`
- `src/autoload/servicios/DialogueActorAnimationService.gd`
- `src/autoload/servicios/DialogueActorRegistryService.gd`
- `src/autoload/servicios/DialogueActorMovementService.gd`
- `scenes/personalizacion/Personalizador.gd`
- `src/personajes/mascota/MascotaAppearance.gd`
- `src/gameplay/enemigos/serpiente/EnemigoHitbox.gd`

## Estado final tras el refactor

- En los directorios `src/autoload/`, `src/autoload/estado/`, `src/autoload/servicios/` y `src/personajes/mascota/` no quedan scripts `.gd` con mayúsculas.
- En `scenes/personalizacion/` permanecen con mayúsculas solo escenas (`.tscn`):
  - `scenes/personalizacion/JugadorBase.tscn`
  - `scenes/personalizacion/Personalizacion.tscn`
