extends Node2D

@export var duracion: float = 1.2
@export var intervalo_parpadeo: float = 0.12

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.texture = preload("res://assets/enemigos/fuego/orange/start/burning_start_1.png")
	sprite.modulate = Color(1.0, 1.0, 1.0, 0.85)
	_reproducir_parpadeo()


func _reproducir_parpadeo() -> void:
	var tween := create_tween()
	var intervalo := maxf(intervalo_parpadeo, 0.01)
	var restante := duracion
	while restante > 0.0:
		tween.tween_callback(func(): sprite.visible = not sprite.visible)
		tween.tween_interval(minf(intervalo, restante))
		restante -= intervalo
	tween.tween_callback(queue_free)
