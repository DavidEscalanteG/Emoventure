extends Node2D
class_name Minijuego1TutorialDemo

@onready var player: Node2D = $Player
@onready var emotion: Node2D = $Emotion
@onready var emotion_sprite: Sprite2D = $Emotion/Sprite2D
@onready var obstacle: Node2D = $Obstacle
@onready var obstacle_sprite: Sprite2D = $Obstacle/Sprite2D

const PLAYER_START := Vector2(240, 360)
const EMOTION_POS := Vector2(650, 300)
const OBSTACLE_POS := Vector2(500, 360)

const PLAYER_SCALE := Vector2.ONE * 1.7
const EMOTION_SCALE := Vector2.ONE * 1.6
const OBSTACLE_SCALE := Vector2.ONE * 3.0

const EMOTION_TEXTURES := {
	"alegria": preload("res://assets/emociones/spritesheets/emocion_feliz.png"),
	"tristeza": preload("res://assets/emociones/spritesheets/emocion_tristeza.png"),
	"enojo": preload("res://assets/emociones/spritesheets/emocion_enojo.png"),
	"desagrado": preload("res://assets/emociones/spritesheets/emocion_desagrado.png"),
	"miedo": preload("res://assets/emociones/spritesheets/emocion_ansiedad.png"),
}

func reset_world() -> void:
	player.position = PLAYER_START
	player.modulate = Color.WHITE
	player.scale = PLAYER_SCALE
	_set_player_movement_state("idle", Vector2.DOWN)
	emotion.position = EMOTION_POS
	emotion.visible = false
	emotion.scale = EMOTION_SCALE
	emotion.modulate = Color.WHITE
	obstacle.position = OBSTACLE_POS
	obstacle.visible = false
	obstacle.scale = OBSTACLE_SCALE
	obstacle_sprite.modulate = Color.WHITE

func move_player(offset: Vector2, duration: float = 0.5) -> Tween:
	_set_player_movement_state("walk", offset)
	var tween := create_tween()
	tween.tween_property(player, "position", player.position + offset, duration)
	tween.finished.connect(func() -> void:
		_set_player_movement_state("idle", offset)
	)
	return tween

func show_emotion(tipo: String) -> void:
	var base_texture: Texture2D = EMOTION_TEXTURES.get(tipo)
	
	if base_texture:
		var atlas := AtlasTexture.new()
		atlas.atlas = base_texture
		atlas.region = Rect2(0, 0, 100, 100)
		
		emotion_sprite.texture = atlas
	
	emotion.visible = true
	emotion.modulate = Color.WHITE
	emotion.scale = EMOTION_SCALE
	emotion.position = EMOTION_POS

func play_emotion_capture_effect() -> Tween:
	var tween := create_tween()
	tween.parallel().tween_property(player, "modulate", Color(1, 0.95, 0.7), 0.2)
	tween.parallel().tween_property(emotion, "position", player.position + Vector2(8, -22), 0.25)
	tween.parallel().tween_property(emotion, "scale", Vector2.ONE * 0.2, 0.25)
	tween.parallel().tween_property(emotion, "modulate", Color(1, 1, 1, 0), 0.25)
	return tween

func show_obstacle() -> void:
	obstacle.visible = true

func play_obstacle_hit_effect() -> Tween:
	var tween := create_tween()
	tween.tween_property(player, "modulate", Color(1, 0.4, 0.4), 0.1)
	tween.tween_property(player, "modulate", Color.WHITE, 0.22)
	tween.parallel().tween_property(obstacle_sprite, "modulate", Color(1, 0.6, 0.6), 0.12)
	tween.parallel().tween_property(obstacle_sprite, "modulate", Color.WHITE, 0.2)
	return tween

func _set_player_movement_state(state: String, direction_vector: Vector2) -> void:
	var appearance: Node = player.get_node_or_null("PlayerAppearance")
	if appearance == null:
		return

	if appearance.has_method("establecer_direccion"):
		appearance.call("establecer_direccion", _vector_to_direction(direction_vector))
	if appearance.has_method("establecer_estado_movimiento"):
		appearance.call("establecer_estado_movimiento", state)

func _vector_to_direction(direction: Vector2) -> String:
	if direction == Vector2.ZERO:
		return "down"

	if abs(direction.x) > abs(direction.y):
		return "right" if direction.x > 0 else "left"

	return "down" if direction.y > 0 else "up"
