extends Area2D

@export var textura: Texture2D
@export var tipo_emocion := ""
@export var color := Color.WHITE
@export var duracion := 5.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if textura:
		sprite.texture = textura

func _on_body_entered(body: Node) -> void:
	if body == DatosJugador.jugador:
		body.aplicar_emocion(tipo_emocion, color, duracion)
		queue_free()
