extends Node
 
const RegistryService = preload("res://src/autoload/servicios/DialogueActorRegistryService.gd")
const AnimationService = preload("res://src/autoload/servicios/DialogueActorAnimationService.gd")
const MovementService = preload("res://src/autoload/servicios/DialogueActorMovementService.gd")
 
const SIGNAL_CINEMATIC_ACTION_FINISHED: String = "cinematic_action_finished"
 
# Plan de deprecación (temporal):
# 1) Mantener esta fachada para scripts existentes.
# 2) Migrar llamadas gradualmente a servicios específicos.
# 3) Retirar la fachada luego de completar la migración de escenas/dialogos.
signal cinematic_action_finished

var cinematica_activa: bool = false
 
var _registro_actores: RefCounted = RegistryService.new()
var _animaciones_actores: RefCounted = AnimationService.new()
var _movimiento_actores: RefCounted = MovementService.new(_animaciones_actores)
 

func register_actor(id: String, nodo: Node) -> void:
	_registro_actores.register_actor(id, nodo)
 
 
func unregister_actor(id: String) -> void:
	_registro_actores.unregister_actor(id)
 

func set_expr(actor_id: String, expresion: String) -> void:
	_animaciones_actores.set_expr(actor_id, _registro_actores.get_actor(actor_id), expresion)
 
 
func set_anim(actor_id: String, estado: String, direccion: String) -> void:
	_animaciones_actores.set_anim(actor_id, _registro_actores.get_actor(actor_id), estado, direccion)
 
 
func play_anim_and_wait(actor_id: String, estado: String, direccion: String) -> void:
	cinematica_activa = true
	await _animaciones_actores.play_anim_and_wait(
		actor_id,
		_registro_actores.get_actor(actor_id),
		estado,
		direccion
	)
	cinematica_activa = false
	emit_signal(SIGNAL_CINEMATIC_ACTION_FINISHED)


func move_and_wait(actor_id: String, delta: Vector2, tiempo: float = 0.6) -> void:
	cinematica_activa = true
	await _movimiento_actores.move_and_wait(
		actor_id,
		_registro_actores.get_actor(actor_id),
		delta,
		tiempo
	)
	cinematica_activa = false
	emit_signal(SIGNAL_CINEMATIC_ACTION_FINISHED)
 

func move_by(actor_id: String, delta: Vector2, tiempo: float = 0.6) -> void:
	_movimiento_actores.move_by(actor_id, _registro_actores.get_actor(actor_id), delta, tiempo)
 

func move_to(actor_id: String, destino: Vector2, tiempo: float = 0.8) -> void:
	_movimiento_actores.move_to(actor_id, _registro_actores.get_actor(actor_id), destino, tiempo)
 
 
func move_left(actor_id: String, pixels: float, tiempo: float = 0.6) -> void:
	move_by(actor_id, Vector2(-pixels, 0), tiempo)

 
func move_right(actor_id: String, pixels: float, tiempo: float = 0.6) -> void:
	move_by(actor_id, Vector2(pixels, 0), tiempo)
 

func move_up(actor_id: String, pixels: float, tiempo: float = 0.6) -> void:
	move_by(actor_id, Vector2(0, -pixels), tiempo)
 

func move_down(actor_id: String, pixels: float, tiempo: float = 0.6) -> void:
	move_by(actor_id, Vector2(0, pixels), tiempo)
 
 
func set_facing(actor_id: String, direction: String) -> void:
	_animaciones_actores.set_facing(actor_id, _registro_actores.get_actor(actor_id), direction)


# Fachadas explícitas por servicio (compatibilidad temporal)
func actor_registry_service() -> RefCounted:
	return _registro_actores


func actor_animation_service() -> RefCounted:
	return _animaciones_actores


func actor_movement_service() -> RefCounted:
	return _movimiento_actores
