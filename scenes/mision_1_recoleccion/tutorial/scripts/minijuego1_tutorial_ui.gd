extends CanvasLayer
class_name Minijuego1TutorialUI

signal previous_pressed
signal next_pressed
signal skip_pressed
signal start_pressed

@onready var message_label: Label = $Overlay/BottomPanel/MarginContainer/VBoxContainer/MessageLabel
@onready var step_label: Label = $Overlay/BottomPanel/MarginContainer/VBoxContainer/StepLabel
@onready var bottom_panel: PanelContainer = $Overlay/BottomPanel
@onready var previous_button: Button = $Overlay/BottomPanel/MarginContainer/VBoxContainer/NavigationRow/PreviousButton
@onready var next_button: Button = $Overlay/BottomPanel/MarginContainer/VBoxContainer/NavigationRow/NextButton
@onready var skip_button: Button = $Overlay/TopBar/SkipButton
@onready var start_button: Button = $Overlay/BottomPanel/MarginContainer/VBoxContainer/NavigationRow/StartButton
@onready var key_map := {
	"W": $Overlay/BottomPanel/MarginContainer/VBoxContainer/KeysRow/WKey,
	"A": $Overlay/BottomPanel/MarginContainer/VBoxContainer/KeysRow/AKey,
	"S": $Overlay/BottomPanel/MarginContainer/VBoxContainer/KeysRow/SKey,
	"D": $Overlay/BottomPanel/MarginContainer/VBoxContainer/KeysRow/DKey,
}

func _ready() -> void:
	_apply_visual_style()
	InteractiveButtonFX.aplicar_a_botones_en(self)
	previous_button.pressed.connect(func() -> void: previous_pressed.emit())
	next_button.pressed.connect(func() -> void: next_pressed.emit())
	skip_button.pressed.connect(func() -> void: skip_pressed.emit())
	start_button.pressed.connect(func() -> void: start_pressed.emit())
	reset_keys()

func set_message(text: String) -> void:
	message_label.text = text

func set_step_indicator(current_step: int, total_steps: int) -> void:
	step_label.text = "GUÍA DE CAMPO  •  PASO %02d DE %02d" % [current_step + 1, total_steps]

func set_navigation(step_index: int, _step_count: int, is_last_step: bool) -> void:
	previous_button.disabled = step_index <= 0
	next_button.visible = not is_last_step
	start_button.visible = is_last_step
	if is_last_step:
		start_button.disabled = false
	next_button.disabled = false

func set_continue_enabled(is_enabled: bool) -> void:
	if next_button.visible:
		next_button.disabled = not is_enabled

func show_keys(is_visible: bool) -> void:
	$Overlay/BottomPanel/MarginContainer/VBoxContainer/KeysRow.visible = is_visible
	if not is_visible:
		reset_keys()

func animate_key(key_name: String) -> void:
	for key in key_map.keys():
		(key_map[key] as KeyVisual).set_active(key == key_name)

func reset_keys() -> void:
	for key in key_map.values():
		(key as KeyVisual).set_active(false)

func _apply_visual_style() -> void:
	bottom_panel.add_theme_stylebox_override("panel", _panel_style(
		Color("#10284aee"), Color("#f6c85f"), 4, 18
	))
	message_label.add_theme_color_override("font_color", Color("#f5f7ff"))
	message_label.add_theme_color_override("font_shadow_color", Color("#07101f"))
	message_label.add_theme_constant_override("shadow_offset_x", 3)
	message_label.add_theme_constant_override("shadow_offset_y", 3)
	step_label.add_theme_color_override("font_color", Color("#ffd978"))
	skip_button.add_theme_stylebox_override("normal", _panel_style(
		Color("#13233ccc"), Color("#7197c6"), 2, 10
	))
	skip_button.add_theme_stylebox_override("hover", _panel_style(
		Color("#22446eee"), Color("#ffd978"), 2, 10
	))
	for button in [previous_button, next_button, start_button]:
		button.custom_minimum_size.y = 52.0
		button.add_theme_color_override("font_color", Color("#f5f7ff"))
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color("#ffd978"))
		button.add_theme_color_override("font_disabled_color", Color("#aeb8cc"))
		button.add_theme_font_size_override("font_size", 24)

func _panel_style(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.01, 0.03, 0.08, 0.65)
	style.shadow_size = 8
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style
