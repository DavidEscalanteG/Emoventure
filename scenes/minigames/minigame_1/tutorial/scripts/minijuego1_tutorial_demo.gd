extends Node2D
class_name Minijuego1TutorialDemo

@onready var player: Node2D = $Player
@onready var player_body: Polygon2D = $Player/Body
@onready var emotion: Node2D = $Emotion
@onready var obstacle: Node2D = $Obstacle
@onready var player_hit_flash: Polygon2D = $Player/HitFlash

const PLAYER_START := Vector2(240, 360)
const EMOTION_POS := Vector2(650, 300)
const OBSTACLE_POS := Vector2(500, 360)

func reset_world() -> void:
	player.position = PLAYER_START
	player.modulate = Color.WHITE
	player_body.color = Color("5ac8fa")
	emotion.position = EMOTION_POS
	emotion.visible = false
	emotion.scale = Vector2.ONE
	obstacle.position = OBSTACLE_POS
	obstacle.visible = false
	player_hit_flash.visible = false
	player_hit_flash.color = Color(1, 0.35, 0.35, 0)

func move_player(offset: Vector2, duration: float = 0.5) -> Tween:
	var tween := create_tween()
	tween.tween_property(player, "position", player.position + offset, duration)
	return tween

func show_emotion() -> void:
	emotion.visible = true
	emotion.modulate = Color(1, 1, 0.6)

func play_emotion_capture_effect() -> void:
	var tween := create_tween()
	tween.parallel().tween_property(player_body, "color", Color("ffd166"), 0.2)
	tween.parallel().tween_property(emotion, "scale", Vector2(0.1, 0.1), 0.25)
	tween.parallel().tween_property(emotion, "modulate", Color(1, 1, 1, 0), 0.25)

func show_obstacle() -> void:
	obstacle.visible = true

func play_obstacle_hit_effect() -> void:
	player_hit_flash.visible = true
	var tween := create_tween()
	tween.tween_property(player_hit_flash, "color", Color(1, 0.25, 0.25, 0.75), 0.12)
	tween.tween_property(player_hit_flash, "color", Color(1, 0.25, 0.25, 0), 0.2)
