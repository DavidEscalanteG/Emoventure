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


# DEPRECADO: usar registrar_actor. Retiro objetivo: 2026-06.
func register_actor(actor_id: String, nodo: Node) -> void:
	registrar_actor(actor_id, nodo)


# DEPRECADO: usar desregistrar_actor. Retiro objetivo: 2026-06.
func unregister_actor(actor_id: String) -> void:
	desregistrar_actor(actor_id)


# DEPRECADO: usar obtener_actor. Retiro objetivo: 2026-06.
func get_actor(actor_id: String) -> Node:
	return obtener_actor(actor_id)


# DEPRECADO: usar tiene_actor. Retiro objetivo: 2026-06.
func has_actor(actor_id: String) -> bool:
	return tiene_actor(actor_id)
