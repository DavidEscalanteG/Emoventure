extends Area2D

@export var tiempo_activo: float = 1.1
@export var tiempo_inactivo: float = 0.9
@export var velocidad_rotacion: float = 6.0

var _activa: bool = true

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var timer_cambio: Timer = $TimerCambio

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	timer_cambio.timeout.connect(_alternar_estado)
	_actualizar_estado_visual()
	timer_cambio.start(tiempo_activo)


func _process(delta: float) -> void:
	if _activa:
		rotation += velocidad_rotacion * delta


func _on_body_entered(body: Node) -> void:
	if not _activa:
		return

	if body.is_in_group("jugador_mision_3") and get_parent().has_method("registrar_golpe"):
		get_parent().registrar_golpe(global_position)


func _alternar_estado() -> void:
	_activa = not _activa
	_actualizar_estado_visual()
	timer_cambio.start(tiempo_activo if _activa else tiempo_inactivo)


func _actualizar_estado_visual() -> void:
	collision.disabled = not _activa
	sprite.modulate = Color(1, 1, 1, 1) if _activa else Color(1, 1, 1, 0.35)
