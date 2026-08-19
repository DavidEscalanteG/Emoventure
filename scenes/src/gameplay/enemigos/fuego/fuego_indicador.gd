extends Node2D

@export var duracion: float = 1.2
@export var intervalo_parpadeo: float = 0.12

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.texture = preload("res://assets/enemigos/fuego/orange/start/burning_start_1.png")
	sprite.modulate = Color(1.0, 1.0, 1.0, 0.85)
	_reproducir_parpadeo()


func _reproducir_parpadeo() -> void:
	var tiempo_transcurrido: float = 0.0
	while tiempo_transcurrido < duracion:
		sprite.visible = not sprite.visible
		await get_tree().create_timer(intervalo_parpadeo).timeout
		tiempo_transcurrido += intervalo_parpadeo
	sprite.visible = true
	queue_free()
