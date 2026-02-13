extends RefCounted

const WARN_PREFIX: String = "[DialogueActors]"
const NODE_ANIMATED_SPRITE: String = "AnimatedSprite2D"
const NODE_PLAYER_APPEARANCE: String = "PlayerAppearance"

# Interfaz mínima esperada para actores con apariencia compleja.
const METHOD_SET_ESTADO_MOVIMIENTO: String = "set_estado_movimiento"
const METHOD_SET_DIRECCION_ES: String = "set_direccion"
const METHOD_SET_DIRECCION_EN: String = "set_direction"

const ESTADO_IDLE: String = "idle"
const ESTADO_WALK: String = "walk"
const ESTADO_RUN: String = "run"

const DIRECCION_DOWN: String = "down"
const DIRECCION_LEFT: String = "left"
const DIRECCION_RIGHT: String = "right"
const DIRECCION_UP: String = "up"

func actor_debug_name(actor_id: String, actor: Node) -> String:
	var node_name: String = "NULL"
	if actor != null:
		node_name = actor.name
	return "actor_id=%s (Nodo=%s)" % [actor_id, node_name]


func warn(actor_id: String, actor: Node, mensaje: String) -> void:
	push_warning("%s %s → %s" % [WARN_PREFIX, mensaje, actor_debug_name(actor_id, actor)])


func establecer_expresion(actor_id: String, actor: Node, expresion: String) -> void:
	if actor == null:
		push_warning("%s Actor no registrado: %s" % [WARN_PREFIX, actor_id])
		return

	if actor.has_node(NODE_ANIMATED_SPRITE):
		var sprite: AnimatedSprite2D = actor.get_node(NODE_ANIMATED_SPRITE)
		sprite.play(expresion)
	else:
		warn(actor_id, actor, "No tiene AnimatedSprite2D")


func establecer_animacion(actor_id: String, actor: Node, estado: String, direccion: String) -> void:
	if actor == null:
		push_warning("%s Actor no registrado: %s" % [WARN_PREFIX, actor_id])
		return

	var estado_normalizado: String = _normalizar_estado(estado)
	var direccion_normalizada: String = _normalizar_direccion(direccion)
	
	if actor.has_node(NODE_ANIMATED_SPRITE):
		_play_npc_animation(actor_id, actor, estado_normalizado, direccion_normalizada)
		return

	if actor.has_node(NODE_PLAYER_APPEARANCE):
		_apply_player_appearance_animation(actor_id, actor, estado, direccion)


func reproducir_animacion_y_esperar(actor_id: String, actor: Node, estado: String, direccion: String) -> void:
	if actor == null:
		push_warning("%s Actor no registrado: %s" % [WARN_PREFIX, actor_id])
		return

	var estado_normalizado: String = _normalizar_estado(estado)
	var direccion_normalizada: String = _normalizar_direccion(direccion)
	
	if actor.has_node(NODE_ANIMATED_SPRITE):
		var sprite: AnimatedSprite2D = actor.get_node(NODE_ANIMATED_SPRITE)
		var anim: String = _anim_name(estado_normalizado, direccion_normalizada)

		if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
			sprite.play(anim)
			await sprite.animation_finished
		else:
			warn(actor_id, actor, "Animación no encontrada: " + anim)
		return

	if actor.has_node(NODE_PLAYER_APPEARANCE):
		var apariencia: Node = actor.get_node(NODE_PLAYER_APPEARANCE)
		_apply_player_interface(actor_id, actor, apariencia, estado_normalizado, direccion_normalizada)

		var cuerpo: AnimatedSprite2D = apariencia.cuerpo
		if cuerpo == null or cuerpo.sprite_frames == null:
			warn(actor_id, actor, "PlayerAppearance sin cuerpo o SpriteFrames")
		else:
			await cuerpo.animation_finished


func establecer_orientacion(actor_id: String, actor: Node, direction: String) -> void:
	if actor == null:
		push_warning("%s Actor no registrado: %s" % [WARN_PREFIX, actor_id])
		return

	if not actor.has_node(NODE_ANIMATED_SPRITE):
		push_warning("%s El actor no tiene AnimatedSprite2D: %s" % [WARN_PREFIX, actor_id])
		return

	var sprite: AnimatedSprite2D = actor.get_node(NODE_ANIMATED_SPRITE)

	var direccion_normalizada: String = _normalizar_direccion(direction)

	match direccion_normalizada:
		DIRECCION_RIGHT:
			sprite.flip_h = false
		DIRECCION_LEFT:
			sprite.flip_h = true
		_:
			push_warning("%s Dirección inválida: %s" % [WARN_PREFIX, direccion_normalizada])


func establecer_idle(actor_id: String, actor: Node) -> void:
	if actor == null:
		return

	if actor.has_node(NODE_PLAYER_APPEARANCE):
		var apariencia: Node = actor.get_node(NODE_PLAYER_APPEARANCE)
		var cuerpo: AnimatedSprite2D = apariencia.cuerpo

		if cuerpo == null or cuerpo.sprite_frames == null:
			warn(actor_id, actor, "PlayerAppearance sin SpriteFrames")
			return

		var anim: String = _anim_name("idle", apariencia.direccion_actual)
		if cuerpo.sprite_frames.has_animation(anim):
			if apariencia.has_method(METHOD_SET_ESTADO_MOVIMIENTO):
				apariencia.call(METHOD_SET_ESTADO_MOVIMIENTO, "idle")
			else:
				warn(actor_id, actor, "No implementa set_estado_movimiento")
		else:
			warn(actor_id, actor, "Animación idle no encontrada: " + anim)
		return

	if actor.has_node(NODE_ANIMATED_SPRITE):
		var sprite: AnimatedSprite2D = actor.get_node(NODE_ANIMATED_SPRITE)

		if sprite.sprite_frames == null:
			warn(actor_id, actor, "NPC sin SpriteFrames")
			return

		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
		else:
			warn(actor_id, actor, "NPC sin animación idle")


func _play_npc_animation(actor_id: String, actor: Node, estado: String, direccion: String) -> void:
	var sprite: AnimatedSprite2D = actor.get_node(NODE_ANIMATED_SPRITE)
	var anim: String = _anim_name(estado, direccion)

	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
	else:
		warn(actor_id, actor, "Animación no encontrada: " + anim)


func _apply_player_appearance_animation(actor_id: String, actor: Node, estado: String, direccion: String) -> void:
	var apariencia: Node = actor.get_node(NODE_PLAYER_APPEARANCE)
	_apply_player_interface(actor_id, actor, apariencia, estado, direccion)


func _apply_player_interface(actor_id: String, actor: Node, apariencia: Node, estado: String, direccion: String) -> void:
	if apariencia.has_method(METHOD_SET_ESTADO_MOVIMIENTO):
		apariencia.call(METHOD_SET_ESTADO_MOVIMIENTO, estado)
	else:
		warn(actor_id, actor, "No implementa set_estado_movimiento")

	if apariencia.has_method(METHOD_SET_DIRECCION_ES):
		apariencia.call(METHOD_SET_DIRECCION_ES, direccion)
	elif apariencia.has_method(METHOD_SET_DIRECCION_EN):
		apariencia.call(METHOD_SET_DIRECCION_EN, direccion)
	else:
		warn(actor_id, actor, "No implementa set_direccion/set_direction")


func _anim_name(estado: String, direccion: String) -> String:
	return "%s_%s" % [_normalizar_estado(estado), _normalizar_direccion(direccion)]


func _normalizar_direccion(direccion: String) -> String:
	match direccion.strip_edges().to_lower():
		"izquierda", DIRECCION_LEFT:
			return DIRECCION_LEFT
		"derecha", DIRECCION_RIGHT:
			return DIRECCION_RIGHT
		"arriba", DIRECCION_UP:
			return DIRECCION_UP
		"abajo", DIRECCION_DOWN:
			return DIRECCION_DOWN
		_:
			return direccion.strip_edges().to_lower()


func _normalizar_estado(estado: String) -> String:
	match estado.strip_edges().to_lower():
		"reposo", "quieto", ESTADO_IDLE:
			return ESTADO_IDLE
		"caminar", "caminando", ESTADO_WALK:
			return ESTADO_WALK
		"correr", "corriendo", ESTADO_RUN:
			return ESTADO_RUN
		_:
			return estado.strip_edges().to_lower()
