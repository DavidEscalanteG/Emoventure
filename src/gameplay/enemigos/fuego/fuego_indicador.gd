extends Node2D

@export var duracion: float = 1.2
@export var intervalo_parpadeo: float = 0.12

@onready var sprite: AnimatedSprite2D = $Sprite2D

var _tiempo_restante: float = 0.0

func _ready() -> void:
	_tiempo_restante = duracion
	sprite.modulate = Color(1.0, 1.0, 1.0, 0.95)
	sprite.play("warning")
	_reproducir_parpadeo()
	queue_redraw()


func _process(delta: float) -> void:
	_tiempo_restante = maxf(_tiempo_restante - delta, 0.0)
	var pulso := 1.0 + sin(Time.get_ticks_msec() * 0.018) * 0.14
	sprite.scale = Vector2.ONE * 1.55 * pulso
	queue_redraw()


func _draw() -> void:
	var progreso := clampf(_tiempo_restante / maxf(duracion, 0.01), 0.0, 1.0)
	# Disco oscuro + aro naranja: el punto exacto de aparición permanece visible
	# aunque el sprite esté en la fase apagada del parpadeo.
	draw_circle(Vector2(0, 4), 19.0, Color(0.16, 0.035, 0.015, 0.48))
	draw_arc(Vector2(0, 4), 22.0, -PI / 2.0, -PI / 2.0 + TAU * progreso, 32, Color("#ff9d32"), 3.0, false)
	for esquina in [Vector2(-19, -17), Vector2(15, -17), Vector2(-19, 19), Vector2(15, 19)]:
		draw_rect(Rect2(esquina, Vector2(4, 4)), Color("#ffe29a"), true)


func _reproducir_parpadeo() -> void:
	var tween := create_tween()
	var intervalo := maxf(intervalo_parpadeo, 0.01)
	var restante := duracion
	while restante > 0.0:
		var paso := minf(intervalo, restante)
		tween.tween_property(sprite, "modulate:a", 0.38, paso * 0.45)
		tween.tween_property(sprite, "modulate:a", 1.0, paso * 0.55)
		restante -= intervalo
	tween.tween_callback(queue_free)
