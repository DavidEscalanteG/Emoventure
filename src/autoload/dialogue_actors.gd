extends Node
 
const RegistryService = preload("res://src/autoload/servicios/dialogue_actor_registry_service.gd")
const AnimationService = preload("res://src/autoload/servicios/dialogue_actor_animation_service.gd")
const MovementService = preload("res://src/autoload/servicios/dialogue_actor_movement_service.gd")

# Plan de deprecación (temporal):
# 1) Mantener esta fachada para scripts existentes.
# 2) Migrar llamadas gradualmente a servicios específicos.
# 3) Retirar la fachada luego de completar la migración de escenas/dialogos.
signal cinematic_action_finished

var cinematica_activa: bool = false
 
var _registro_actores: RefCounted = RegistryService.new()
var _animaciones_actores: RefCounted = AnimationService.new()
var _movimiento_actores: RefCounted = MovementService.new(_animaciones_actores)


func reiniciar_estado_cinematica() -> void:
	# Una escena puede liberar al actor mientras un tween está siendo esperado.
	# En ese caso `finished` no se emite y la bandera global quedaría bloqueada.
	cinematica_activa = false
	cinematic_action_finished.emit()
 

# =========================
# API DE SERVICIOS (PÚBLICA)
# =========================
func registro_registrar_actor(id: String, nodo: Node) -> void:
	_registro_actores.registrar_actor(id, nodo)


func registro_desregistrar_actor(id: String) -> void:
	_registro_actores.desregistrar_actor(id)


func animacion_establecer_expresion(actor_id: String, expresion: String) -> void:
	_animaciones_actores.establecer_expresion(actor_id, _registro_actores.obtener_actor(actor_id), expresion)


func animacion_establecer_animacion(actor_id: String, estado: String, direccion: String) -> void:
	_animaciones_actores.establecer_animacion(actor_id, _registro_actores.obtener_actor(actor_id), estado, direccion)


func animacion_reproducir_y_esperar(actor_id: String, estado: String, direccion: String) -> void:
	cinematica_activa = true
	await _animaciones_actores.reproducir_animacion_y_esperar(
		actor_id,
		_registro_actores.obtener_actor(actor_id),
		estado,
		direccion
	)
	cinematica_activa = false
	cinematic_action_finished.emit()


func movimiento_mover_y_esperar(actor_id: String, delta: Vector2, tiempo: float = 0.6) -> void:
	cinematica_activa = true
	await _movimiento_actores.mover_y_esperar(
		actor_id,
		_registro_actores.obtener_actor(actor_id),
		delta,
		tiempo
	)
	cinematica_activa = false
	cinematic_action_finished.emit()


func movimiento_mover_por(actor_id: String, delta: Vector2, tiempo: float = 0.6) -> void:
	_movimiento_actores.mover_por(actor_id, _registro_actores.obtener_actor(actor_id), delta, tiempo)


func movimiento_mover_a(actor_id: String, destino: Vector2, tiempo: float = 0.8) -> void:
	_movimiento_actores.mover_a(actor_id, _registro_actores.obtener_actor(actor_id), destino, tiempo)


func movimiento_mover_derecha(actor_id: String, distancia: float, tiempo: float = 0.6) -> void:
	movimiento_mover_por(actor_id, Vector2(distancia, 0), tiempo)


func movimiento_mover_izquierda(actor_id: String, distancia: float, tiempo: float = 0.6) -> void:
	movimiento_mover_por(actor_id, Vector2(-distancia, 0), tiempo)
