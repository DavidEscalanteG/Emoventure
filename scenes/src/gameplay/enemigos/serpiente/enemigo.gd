extends CharacterBody2D

@export var speed: float = 150.0

var path_follow: PathFollow2D = null
var ruta_pendiente: Path2D = null
var esperando_cambio: bool = false
var en_interseccion: bool = false

var puede_moverse: bool = true
var ultima_direccion: Vector2 = Vector2.RIGHT
var ultima_posicion_global: Vector2 = Vector2.ZERO

@onready var visual: Node2D = $Visual
@onready var sprite: AnimatedSprite2D = $Visual/AnimatedSprite2D

func _ready() -> void:
	path_follow = get_parent() as PathFollow2D
	if path_follow != null:
		path_follow.rotates = false
		path_follow.rotation = 0.0
	sprite.play("walk") # arranca caminando por default
	visual.scale = Vector2.ONE
	ultima_posicion_global = global_position
	_actualizar_orientacion(ultima_direccion)

func _physics_process(delta: float) -> void:
	if not puede_moverse:
		_actualizar_animacion()
		_actualizar_orientacion(Vector2.ZERO)
		return

	if path_follow == null:
		return

	path_follow.progress += speed * delta
	_actualizar_animacion()

	var movimiento: Vector2 = global_position - ultima_posicion_global
	_actualizar_orientacion(movimiento)
	ultima_posicion_global = global_position

	# 🔀 Cambio de ruta SOLO si sigue en intersección
	if esperando_cambio and en_interseccion:
		if path_follow.progress_ratio >= 1.0 or path_follow.progress_ratio <= 0.0:
			_ejecutar_cambio_de_ruta()
		return

	# ↩ Callejón SOLO si NO hay ruta pendiente
	if not esperando_cambio:
		if path_follow.progress_ratio >= 1.0 and speed > 0:
			speed = -abs(speed)

		elif path_follow.progress_ratio <= 0.0 and speed < 0:
			speed = abs(speed)

	elif path_follow.progress_ratio <= 0.0 and speed < 0:
		speed = abs(speed)

func _actualizar_animacion() -> void:
	if not puede_moverse or abs(speed) < 0.01:
		if sprite.animation != "idle":
			sprite.play("idle")
	else:
		if sprite.animation != "walk":
			sprite.play("walk")

func _actualizar_orientacion(movimiento: Vector2) -> void:
	if movimiento.length_squared() > 0.0001:
		if abs(movimiento.x) > abs(movimiento.y):
			ultima_direccion = Vector2.RIGHT if movimiento.x > 0.0 else Vector2.LEFT
		else:
			ultima_direccion = Vector2.DOWN if movimiento.y > 0.0 else Vector2.UP

	sprite.flip_h = false
	visual.rotation = 0.0

	match ultima_direccion:
		Vector2.RIGHT:
			sprite.flip_h = true
			visual.rotation = 0.0
		Vector2.LEFT:
			visual.rotation = 0.0
		Vector2.UP:
			visual.rotation = PI / 2.0
		Vector2.DOWN:
			visual.rotation = -PI / 2.0


func preparar_cambio_de_ruta(nueva_ruta: Path2D) -> void:
	ruta_pendiente = nueva_ruta
	esperando_cambio = true

func _ejecutar_cambio_de_ruta() -> void:
	if ruta_pendiente == null:
		return

	var nueva_follow: PathFollow2D = PathFollow2D.new()
	nueva_follow.loop = false
	nueva_follow.rotates = false
	nueva_follow.rotation = 0.0

	# ⬅️ 1. Añadir PRIMERO al Path2D
	ruta_pendiente.add_child(nueva_follow)

	# ⬅️ 2. Ahora SÍ podemos usar la curva
	var curva: Curve2D = ruta_pendiente.curve
	var inicio: Vector2 = ruta_pendiente.to_global(curva.get_point_position(0))
	var final: Vector2 = ruta_pendiente.to_global(curva.get_point_position(curva.point_count - 1))


	if global_position.distance_to(final) < global_position.distance_to(inicio):
		nueva_follow.progress_ratio = 1.0
		speed = -abs(speed)
		Logs.log_debug("↩ Entrando por final")
	else:
		nueva_follow.progress_ratio = 0.0
		speed = abs(speed)
		Logs.log_debug("➡ Entrando por inicio")

	# ⬅️ 3. Reparentar enemigo
	reparent(nueva_follow)
	position = Vector2.ZERO

	# ⬅️ 4. Limpiar
	path_follow.queue_free()
	path_follow = nueva_follow
	ultima_posicion_global = global_position

	ruta_pendiente = null
	esperando_cambio = false

func bloquear_movimiento() -> void:
	puede_moverse = false

func permitir_movimiento() -> void:
	puede_moverse = true
