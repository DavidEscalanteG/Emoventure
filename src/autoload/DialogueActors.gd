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


func registrar_actor(id: String, nodo: Node) -> void:
	register_actor(id, nodo)
 
 
func unregister_actor(id: String) -> void:
	_registro_actores.unregister_actor(id)


func desregistrar_actor(id: String) -> void:
	unregister_actor(id)
 

func set_expr(actor_id: String, expresion: String) -> void:
	_animaciones_actores.set_expr(actor_id, _registro_actores.get_actor(actor_id), expresion)


func establecer_expresion(actor_id: String, expresion: String) -> void:
	set_expr(actor_id, expresion)
 
 
func set_anim(actor_id: String, estado: String, direccion: String) -> void:
	_animaciones_actores.set_anim(actor_id, _registro_actores.get_actor(actor_id), estado, direccion)


func establecer_animacion(actor_id: String, estado: String, direccion: String) -> void:
	set_anim(actor_id, estado, direccion)
 
 
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


func mover_y_esperar(actor_id: String, delta: Vector2, tiempo: float = 0.6) -> void:
	await move_and_wait(actor_id, delta, tiempo)


func mover_izquierda(actor_id: String, distancia: float, tiempo: float = 0.6) -> void:
	await mover_y_esperar(actor_id, Vector2(-distancia, 0), tiempo)


func mover_derecha(actor_id: String, distancia: float, tiempo: float = 0.6) -> void:
	await mover_y_esperar(actor_id, Vector2(distancia, 0), tiempo)


func mover_arriba(actor_id: String, distancia: float, tiempo: float = 0.6) -> void:
	await mover_y_esperar(actor_id, Vector2(0, -distancia), tiempo)


func mover_abajo(actor_id: String, distancia: float, tiempo: float = 0.6) -> void:
	await mover_y_esperar(actor_id, Vector2(0, distancia), tiempo)
