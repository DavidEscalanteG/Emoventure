extends CanvasLayer
class_name Minijuego2TutorialUI

signal previous_pressed
signal next_pressed
signal start_pressed
signal skip_pressed

@onready var dark_overlay: ColorRect = $Overlay/DarkOverlay
@onready var message_label: Label = $Overlay/BottomPanel/MarginContainer/VBoxContainer/MessageLabel
@onready var step_label: Label = $Overlay/BottomPanel/MarginContainer/VBoxContainer/StepLabel
@onready var previous_button: Button = $Overlay/BottomPanel/MarginContainer/VBoxContainer/NavigationRow/PreviousButton
@onready var next_button: Button = $Overlay/BottomPanel/MarginContainer/VBoxContainer/NavigationRow/NextButton
@onready var start_button: Button = $Overlay/BottomPanel/MarginContainer/VBoxContainer/NavigationRow/StartButton
@onready var skip_button: Button = $Overlay/TopBar/SkipButton
@onready var bottom_panel: PanelContainer = $Overlay/BottomPanel

func _ready() -> void:
	_apply_visual_style()
	InteractiveButtonFX.aplicar_a_botones_en(self)
	previous_button.pressed.connect(func() -> void: previous_pressed.emit())
	next_button.pressed.connect(func() -> void: next_pressed.emit())
	start_button.pressed.connect(func() -> void: start_pressed.emit())
	skip_button.pressed.connect(func() -> void: skip_pressed.emit())

func set_message(text: String) -> void:
	message_label.text = text

func set_step_indicator(current_step: int, total_steps: int) -> void:
	step_label.text = "RECUERDO %02d  •  PASO %d DE %d" % [current_step + 1, current_step + 1, total_steps]

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

func set_overlay_alpha(alpha: float) -> void:
	dark_overlay.color = Color(0, 0, 0, clampf(alpha, 0.0, 1.0))

func _apply_visual_style() -> void:
	bottom_panel.add_theme_stylebox_override("panel", _panel_style(
		Color("#281c39f2"), Color("#efc56b"), 4, 18
	))
	message_label.add_theme_color_override("font_color", Color("#fff8e7"))
	message_label.add_theme_color_override("font_shadow_color", Color("#160d21"))
	message_label.add_theme_constant_override("shadow_offset_x", 3)
	message_label.add_theme_constant_override("shadow_offset_y", 3)
	step_label.add_theme_color_override("font_color", Color("#f3ce7a"))
	skip_button.add_theme_stylebox_override("normal", _panel_style(
		Color("#251a35dd"), Color("#9b78b7"), 2, 10
	))
	skip_button.add_theme_stylebox_override("hover", _panel_style(
		Color("#4b3269f2"), Color("#f3ce7a"), 2, 10
	))
	for button in [previous_button, next_button, start_button]:
		button.custom_minimum_size.y = 52.0

func _panel_style(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.04, 0.01, 0.08, 0.7)
	style.shadow_size = 9
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style
