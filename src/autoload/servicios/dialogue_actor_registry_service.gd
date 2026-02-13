extends RefCounted

const WARN_PREFIX: String = "[DialogueActors]"

var _actores: Dictionary = {}

func registrar_actor(actor_id: String, nodo: Node) -> void:
	_actores[actor_id] = nodo


func desregistrar_actor(actor_id: String) -> void:
	_actores.erase(actor_id)


func obtener_actor(actor_id: String) -> Node:
	if not _actores.has(actor_id):
		push_warning("%s Actor no registrado: %s" % [WARN_PREFIX, actor_id])
		return null
	return _actores[actor_id]


func tiene_actor(actor_id: String) -> bool:
	return _actores.has(actor_id)
