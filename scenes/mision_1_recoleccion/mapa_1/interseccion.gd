extends Area2D

@export var rutas_disponibles: Array[Path2D]
@export var cooldown_interseccion: float = 1.0

# Enemigos que ya cambiaron ruta en esta intersección
var enemigos_bloqueados: Dictionary = {}

func _on_body_entered(body: Node) -> void:
	if not (body is CharacterBody2D):
		return

	var enemigo: CharacterBody2D = body
	
	enemigo.en_interseccion = true

	if enemigos_bloqueados.has(enemigo):
		return

	enemigos_bloqueados[enemigo] = true

	var path_follow: PathFollow2D = enemigo.get_parent() as PathFollow2D
	if path_follow == null:
		return

	var rutas_validas: Array[Path2D] = rutas_disponibles.duplicate()

	var path_actual: Path2D = path_follow.get_parent() as Path2D
	if path_actual != null and path_actual in rutas_validas:
		rutas_validas.erase(path_actual)

	if rutas_validas.is_empty():
		return

	var nueva_ruta: Path2D = rutas_validas.pick_random()
	Logs.log_debug("✅ Nueva ruta elegida: %s para: %s en: %s" % [nueva_ruta.name, enemigo.name, name])

	enemigo.preparar_cambio_de_ruta(nueva_ruta)

	# ⏱ Liberar bloqueo después del cooldown
	_desbloquear_despues(enemigo)

func _desbloquear_despues(enemigo: CharacterBody2D) -> void:
	await get_tree().create_timer(cooldown_interseccion).timeout

	if enemigos_bloqueados.has(enemigo):
		enemigos_bloqueados.erase(enemigo)

func _on_body_exited(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return

	var enemigo := body as CharacterBody2D

	enemigo.en_interseccion = false
	enemigo.esperando_cambio = false
	enemigo.ruta_pendiente = null
