extends Area2D

@export var textura: Texture2D
@export var tipo_emocion := ""
@export var color := Color.WHITE
@export var duracion := 5.0
@export var amplitud_movimiento := Vector2(12.0, 0.0)
@export_range(0.5, 5.0, 0.1) var tiempo_movimiento := 1.4

@onready var sprite: Sprite2D = $Sprite2D

var _posicion_inicial: Vector2

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if textura:
		sprite.texture = textura

	_posicion_inicial = position
	_animar_emocion()

func _on_body_entered(body: Node) -> void:
	if body == DatosJugador.jugador:
		body.aplicar_emocion(tipo_emocion, color, duracion)
		queue_free()


func _animar_emocion() -> void:
	# Mantiene cada emoción claramente viva dentro del laberinto sin sacarla
	# del corredor ni permitir que atraviese paredes.
	var movimiento := create_tween().set_loops()
	movimiento.set_trans(Tween.TRANS_SINE)
	movimiento.set_ease(Tween.EASE_IN_OUT)
	movimiento.tween_property(self, "position", _posicion_inicial + amplitud_movimiento, tiempo_movimiento)
	movimiento.tween_property(self, "position", _posicion_inicial - amplitud_movimiento, tiempo_movimiento * 2.0)
	movimiento.tween_property(self, "position", _posicion_inicial, tiempo_movimiento)

	var pulso := create_tween().set_loops()
	pulso.set_trans(Tween.TRANS_SINE)
	pulso.set_ease(Tween.EASE_IN_OUT)
	pulso.tween_property(sprite, "scale", Vector2.ONE * 1.08, tiempo_movimiento * 0.5)
	pulso.tween_property(sprite, "scale", Vector2.ONE, tiempo_movimiento * 0.5)
