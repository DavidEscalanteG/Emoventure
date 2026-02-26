extends PanelContainer
class_name KeyVisual

@export var key_text: String = "W":
	set(value):
		key_text = value
		if is_node_ready():
			_label.text = key_text

@onready var _label: Label = $Label

var _idle_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	custom_minimum_size = Vector2(56, 56)
	_label.text = key_text
	modulate = Color(1, 1, 1, 0.65)
	scale = _idle_scale

func set_active(is_active: bool) -> void:
	if is_active:
		modulate = Color(1, 1, 1, 1)
		var tween := create_tween()
		tween.tween_property(self, "scale", Vector2(0.88, 0.88), 0.08)
		tween.tween_property(self, "scale", _idle_scale, 0.08)
	else:
		modulate = Color(1, 1, 1, 0.65)
		scale = _idle_scale
