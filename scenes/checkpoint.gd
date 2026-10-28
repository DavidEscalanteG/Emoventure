extends Area2D

@onready var punto_aparicion: Marker2D = $PuntoAparicion

var activado: bool = false

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if activado:
		return

	if body.has_method("registrar_checkpoint"):
		activado = true
		
		# Si existe el Marker2D, toma su posición exacta. Si no, toma la del Area2D.
		var pos_reaparicion: Vector2 = global_position
		if punto_aparicion != null:
			pos_reaparicion = punto_aparicion.global_position

		# Obtenemos el tiempo actual de la música
		var tiempo_actual: float = 0.0
		if MusicManager.has_method("obtener_posicion_reproduccion"):
			tiempo_actual = MusicManager.obtener_posicion_reproduccion()

		# Guardamos los datos en el jugador
		body.registrar_checkpoint(pos_reaparicion, tiempo_actual)
