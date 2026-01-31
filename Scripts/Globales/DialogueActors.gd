extends Node

# ==================================================
# REGISTRO DE ACTORES
# ==================================================
var actores: Dictionary = {}

func register_actor(id: String, nodo: Node) -> void:
	actores[id] = nodo

func unregister_actor(id: String) -> void:
	actores.erase(id)


# ==================================================
# EXPRESIONES / ANIMACIONES
# ==================================================
func set_expr(actor_id: String, expresion: String) -> void:
	if not actores.has(actor_id):
		push_warning("Actor no registrado: " + actor_id)
		return

	var actor: Node = actores[actor_id]

	if actor.has_node("AnimatedSprite2D"):
		var sprite: AnimatedSprite2D = actor.get_node("AnimatedSprite2D")
		sprite.play(expresion)
	else:
		push_warning("El actor no tiene AnimatedSprite2D: " + actor_id)


func set_anim(actor_id: String, estado: String, direccion: String) -> void:
	if not actores.has(actor_id):
		push_warning("Actor no registrado: " + actor_id)
		return

	var actor: Node = actores[actor_id]

	# NPC clásico
	if actor.has_node("AnimatedSprite2D"):
		var sprite: AnimatedSprite2D = actor.get_node("AnimatedSprite2D")
		var anim: String = estado + "_" + direccion

		if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
			sprite.play(anim)
		else:
			push_warning("Animación no encontrada: " + anim)
		return

	# Jugador no jugable
	if actor.has_node("PlayerAppearance"):
		var apariencia: Node = actor.get_node("PlayerAppearance")
		apariencia.set_estado_movimiento(estado)
		apariencia.set_direction(direccion)


# ==================================================
# MOVIMIENTO CINEMÁTICO (TWEEN)
# ==================================================
func move_by(actor_id: String, delta: Vector2, tiempo: float = 0.6) -> void:
	if not actores.has(actor_id):
		push_warning("Actor no registrado: " + actor_id)
		return

	var actor: Node2D = actores[actor_id] as Node2D
	if actor == null:
		push_warning("Actor no es Node2D: " + actor_id)
		return

	var tween: Tween = actor.create_tween()
	tween.tween_property(
		actor,
		"global_position",
		actor.global_position + delta,
		tiempo
	)

	tween.finished.connect(func():
		_try_set_idle(actor)
	)


func move_to(actor_id: String, destino: Vector2, tiempo: float = 0.8) -> void:
	if not actores.has(actor_id):
		push_warning("Actor no registrado: " + actor_id)
		return

	var actor: Node2D = actores[actor_id] as Node2D
	if actor == null:
		push_warning("Actor no es Node2D: " + actor_id)
		return

	var tween: Tween = actor.create_tween()
	tween.tween_property(actor, "global_position", destino, tiempo)

	tween.finished.connect(func():
		_try_set_idle(actor)
	)


# ==================================================
# MOVIMIENTOS DE CONVENIENCIA
# ==================================================
func move_left(actor_id: String, pixels: float, tiempo: float = 0.6) -> void:
	move_by(actor_id, Vector2(-pixels, 0), tiempo)

func move_right(actor_id: String, pixels: float, tiempo: float = 0.6) -> void:
	move_by(actor_id, Vector2(pixels, 0), tiempo)

func move_up(actor_id: String, pixels: float, tiempo: float = 0.6) -> void:
	move_by(actor_id, Vector2(0, -pixels), tiempo)

func move_down(actor_id: String, pixels: float, tiempo: float = 0.6) -> void:
	move_by(actor_id, Vector2(0, pixels), tiempo)


# ==================================================
# ORIENTACIÓN SIMPLE (NPCs)
# ==================================================
func set_facing(actor_id: String, direction: String) -> void:
	if not actores.has(actor_id):
		push_warning("Actor no registrado: " + actor_id)
		return

	var actor: Node = actores[actor_id]

	if not actor.has_node("AnimatedSprite2D"):
		push_warning("El actor no tiene AnimatedSprite2D: " + actor_id)
		return

	var sprite: AnimatedSprite2D = actor.get_node("AnimatedSprite2D")

	match direction.to_lower():
		"right":
			sprite.flip_h = false
		"left":
			sprite.flip_h = true
		_:
			push_warning("Dirección inválida: " + direction)


# ==================================================
# FINALIZAR MOVIMIENTO → IDLE (SEGURO)
# ==================================================
func _try_set_idle(actor: Node) -> void:
	# Jugador / PlayerAppearance
	if actor.has_node("PlayerAppearance"):
		var apariencia: Node = actor.get_node("PlayerAppearance")
		var cuerpo: AnimatedSprite2D = apariencia.cuerpo

		if cuerpo == null or cuerpo.sprite_frames == null:
			push_warning("PlayerAppearance sin SpriteFrames")
			return

		var anim: String = "idle_" + apariencia.direccion_actual
		if cuerpo.sprite_frames.has_animation(anim):
			apariencia.set_estado_movimiento("idle")
		else:
			push_warning("Animación no encontrada: " + anim)
		return

	# NPC clásico
	if actor.has_node("AnimatedSprite2D"):
		var sprite: AnimatedSprite2D = actor.get_node("AnimatedSprite2D")

		if sprite.sprite_frames == null:
			push_warning("NPC sin SpriteFrames")
			return

		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
		else:
			push_warning("NPC sin animación idle")
