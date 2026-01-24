extends Node

var actores: Dictionary = {}


func register_actor(id: String, nodo: Node) -> void:
	actores[id] = nodo


func unregister_actor(id: String) -> void:
	actores.erase(id)


# ===============================
# LLAMADO DESDE do set_expr()
# ===============================
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
