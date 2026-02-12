extends RefCounted

const WARN_PREFIX: String = "[DialogueActors]"

var _animation_service: RefCounted

func _init(animation_service: RefCounted) -> void:
	_animation_service = animation_service


func move_and_wait(actor_id: String, actor: Node, delta: Vector2, tiempo: float = 0.6) -> void:
	var actor_2d: Node2D = actor as Node2D
	if actor_2d == null:
		push_warning("%s Actor no es Node2D: %s" % [WARN_PREFIX, actor_id])
		return

	var tween: Tween = actor_2d.create_tween()
	tween.tween_property(actor_2d, "global_position", actor_2d.global_position + delta, tiempo)
	await tween.finished
	_animation_service.set_idle(actor_id, actor_2d)


func move_by(actor_id: String, actor: Node, delta: Vector2, tiempo: float = 0.6) -> void:
	var actor_2d: Node2D = actor as Node2D
	if actor_2d == null:
		push_warning("%s Actor no es Node2D: %s" % [WARN_PREFIX, actor_id])
		return

	var tween: Tween = actor_2d.create_tween()
	tween.tween_property(actor_2d, "global_position", actor_2d.global_position + delta, tiempo)
	tween.finished.connect(func() -> void:
		_animation_service.set_idle(actor_id, actor_2d)
	)


func move_to(actor_id: String, actor: Node, destino: Vector2, tiempo: float = 0.8) -> void:
	var actor_2d: Node2D = actor as Node2D
	if actor_2d == null:
		push_warning("%s Actor no es Node2D: %s" % [WARN_PREFIX, actor_id])
		return

	var tween: Tween = actor_2d.create_tween()
	tween.tween_property(actor_2d, "global_position", destino, tiempo)
	tween.finished.connect(func() -> void:
		_animation_service.set_idle(actor_id, actor_2d)
	)
