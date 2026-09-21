extends PanelContainer
class_name KeyVisual

@export var key_text: String = "W":
	set(value):
		key_text = value
		if is_node_ready():
			_label.text = key_text

@onready var _label: Label = $Label

var _idle_scale: Vector2 = Vector2.ONE
var _highlight_tween: Tween

func _ready() -> void:
	custom_minimum_size = Vector2(56, 56)
	_label.text = key_text
	modulate = Color(1, 1, 1, 0.65)
	scale = _idle_scale

func set_active(is_active: bool) -> void:
	if _highlight_tween != null and _highlight_tween.is_valid():
		_highlight_tween.kill()
	if is_active:
		# El amarillo brillante distingue claramente la tecla que se está "presionando".
		modulate = Color(1.35, 1.05, 0.25, 1)
		_highlight_tween = create_tween()
		_highlight_tween.tween_property(self, "scale", Vector2(1.18, 1.18), 0.12)
		_highlight_tween.tween_property(self, "scale", _idle_scale, 0.12)
	else:
		modulate = Color(1, 1, 1, 0.65)
		scale = _idle_scale
