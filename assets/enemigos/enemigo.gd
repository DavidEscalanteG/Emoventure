extends CharacterBody2D

@export var speed: float = 150.0

var path_follow: PathFollow2D = null
var ruta_pendiente: Path2D = null
var esperando_cambio: bool = false
var en_interseccion: bool = false

var puede_moverse: bool = true

func _ready() -> void:
	path_follow = get_parent() as PathFollow2D

func _physics_process(delta: float) -> void:
	if not puede_moverse:
		return

	if path_follow == null:
		return

	path_follow.progress += speed * delta

	# 🔀 Cambio de ruta SOLO si sigue en intersección
	if esperando_cambio and en_interseccion:
		if path_follow.progress_ratio >= 1.0 or path_follow.progress_ratio <= 0.0:
			_ejecutar_cambio_de_ruta()
		return

	# ↩ Callejón SOLO si NO hay ruta pendiente
	if not esperando_cambio:
		if path_follow.progress_ratio >= 1.0 and speed > 0:
			print("↪↪Callejon de ", name, "con ratio de ", path_follow.progress_ratio, " y velocidad de ", speed, " no esperando cambio")
			speed = -abs(speed)
			print("↩ Callejón: invirtiendo dirección de: ", name)

		elif path_follow.progress_ratio <= 0.0 and speed < 0:
			print("↪↪Callejon de ", name, "con ratio de ", path_follow.progress_ratio, " y velocidad de ", speed, " no esperando cambio")
			speed = abs(speed)
			print("↪ Callejón: invirtiendo dirección de: ", name)

	elif path_follow.progress_ratio <= 0.0 and speed < 0:
		print("↪↪Callejon de ", name, "con ratio de ", path_follow.progress_ratio, " y velocidad de ", speed, " esperando cambio")
		speed = abs(speed)
		print("↪ Callejón: invirtiendo dirección (inicio del path) de: ", name)

func preparar_cambio_de_ruta(nueva_ruta: Path2D) -> void:
	ruta_pendiente = nueva_ruta
	esperando_cambio = true

func _ejecutar_cambio_de_ruta() -> void:
	if ruta_pendiente == null:
		return

	var nueva_follow: PathFollow2D = PathFollow2D.new()
	nueva_follow.loop = false

	# ⬅️ 1. Añadir PRIMERO al Path2D
	ruta_pendiente.add_child(nueva_follow)

	# ⬅️ 2. Ahora SÍ podemos usar la curva
	var curva: Curve2D = ruta_pendiente.curve
	var inicio: Vector2 = ruta_pendiente.to_global(curva.get_point_position(0))
	var final: Vector2 = ruta_pendiente.to_global(curva.get_point_position(curva.point_count - 1))

	print("Distancia inicio:", global_position.distance_to(inicio),
		  "distancia final:", global_position.distance_to(final))

	if global_position.distance_to(final) < global_position.distance_to(inicio):
		nueva_follow.progress_ratio = 1.0
		speed = -abs(speed)
		print("↩ Entrando por final")
	else:
		nueva_follow.progress_ratio = 0.0
		speed = abs(speed)
		print("➡ Entrando por inicio")

	# ⬅️ 3. Reparentar enemigo
	reparent(nueva_follow)
	position = Vector2.ZERO

	# ⬅️ 4. Limpiar
	path_follow.queue_free()
	path_follow = nueva_follow

	ruta_pendiente = null
	esperando_cambio = false

func bloquear_movimiento():
	puede_moverse = false

func permitir_movimiento():
	puede_moverse = true
