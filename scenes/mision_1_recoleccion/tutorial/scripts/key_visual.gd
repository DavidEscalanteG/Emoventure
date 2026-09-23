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
	add_theme_stylebox_override("panel", _make_key_style(Color("#162f52"), Color("#82b7e8")))
	_label.add_theme_color_override("font_color", Color("#f7fbff"))
	_label.add_theme_color_override("font_shadow_color", Color("#06101e"))
	_label.add_theme_constant_override("shadow_offset_x", 2)
	_label.add_theme_constant_override("shadow_offset_y", 2)
	modulate = Color(1, 1, 1, 0.65)
	scale = _idle_scale

func set_active(is_active: bool) -> void:
	if _highlight_tween != null and _highlight_tween.is_valid():
		_highlight_tween.kill()
	if is_active:
		# El amarillo brillante distingue claramente la tecla que se está "presionando".
		modulate = Color(1.35, 1.05, 0.25, 1)
		add_theme_stylebox_override("panel", _make_key_style(Color("#704414"), Color("#ffe07a")))
		_highlight_tween = create_tween()
		_highlight_tween.tween_property(self, "scale", Vector2(1.18, 1.18), 0.12)
		_highlight_tween.tween_property(self, "scale", _idle_scale, 0.12)
	else:
		modulate = Color(1, 1, 1, 0.65)
		add_theme_stylebox_override("panel", _make_key_style(Color("#162f52"), Color("#82b7e8")))
		scale = _idle_scale

func _make_key_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(3)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0, 0, 0, 0.55)
	style.shadow_size = 5
	return style
