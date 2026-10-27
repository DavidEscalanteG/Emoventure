extends Control

const MISSION_SCENE := "res://scenes/mision_3_nuevo/minijuego3.tscn"
const MESSAGES: Array[String] = [
	"Tu personaje avanza automáticamente. Tu tarea es elegir el momento correcto para saltar.",
	"Presiona ESPACIO, flecha arriba o haz clic para saltar los pinchos. En celular, toca la pantalla.",
	"Evita pinchos y más obstáculos. Si los tocas, el nivel comenzará de nuevo.",
	"Llega hasta la puerta al final del recorrido para completar la misión.",
	"¡Todo listo! Mantén la calma, observa el camino y salta en el momento preciso."
]

@onready var message_label: Label = %MessageLabel
@onready var step_label: Label = %StepLabel
@onready var previous_button: Button = %PreviousButton
@onready var next_button: Button = %NextButton
@onready var start_button: Button = %StartButton
@onready var player: CharacterBody2D = %Player
@onready var jump_hint: Label = %JumpHint
@onready var danger: Control = %Danger
@onready var goal: Control = %Goal
@onready var arena_frame: Panel = %ArenaFrame
@onready var bottom_panel: PanelContainer = $Bottom
@onready var title_label: Label = $Title

var _step := 0
var _animation_token := 0
const STEP_END_DELAY := 0.3

func _ready() -> void:
	InteractiveButtonFX.aplicar_a_botones_en(self)
	previous_button.pressed.connect(func() -> void: _show_step(_step - 1))
	next_button.pressed.connect(func() -> void: _show_step(_step + 1))
	start_button.pressed.connect(_start_mission)
	%SkipButton.pressed.connect(_start_mission)
	_apply_visual_style()
	_show_step(0)

func _show_step(value: int) -> void:
	_step = clampi(value, 0, MESSAGES.size() - 1)
	_animation_token += 1
	message_label.text = MESSAGES[_step]
	step_label.text = "%s   PASO %d DE %d" % [_progress_dots(), _step + 1, MESSAGES.size()]
	previous_button.disabled = true
	next_button.visible = _step < MESSAGES.size() - 1
	start_button.visible = _step == MESSAGES.size() - 1
	next_button.disabled = true
	start_button.disabled = true
	_reset_demo()
	_play_demo(_animation_token)
	message_label.modulate.a = 0.0
	create_tween().tween_property(message_label, "modulate:a", 1.0, 0.18)

func _reset_demo() -> void:
	player.position = Vector2(180, 350)
	player.rotation = 0.0
	player.modulate = Color.WHITE
	jump_hint.visible = false
	danger.modulate = Color(1, 1, 1, 0.45)
	goal.modulate = Color(1, 1, 1, 0.45)

func _play_demo(token: int) -> void:
	var tween: Tween
	match _step:
		0:
			tween = create_tween().set_loops(2)
			tween.tween_property(player, "position:x", 420.0, 0.8)
			tween.tween_property(player, "position:x", 180.0, 0.0)
		1:
			jump_hint.visible = true
			tween = _jump_tween(735.0, true)
		2:
			danger.modulate = Color.WHITE
			tween = _jump_tween(735.0, false)
		3:
			goal.modulate = Color.WHITE
			tween = _pulse(goal)
		4:
			danger.modulate = Color.WHITE
			goal.modulate = Color.WHITE
			tween = _jump_tween(735.0, false)
			tween.tween_property(player, "position", Vector2(835, 350), 0.32)
	if tween != null:
		await tween.finished
	if token != _animation_token:
		return
	await get_tree().create_timer(STEP_END_DELAY).timeout
	if token != _animation_token:
		return
	previous_button.disabled = _step == 0
	next_button.disabled = false
	start_button.disabled = false

func _jump_tween(landing_x: float, repeat: bool) -> Tween:
	var tween := create_tween().set_loops(2 if repeat else 1)
	# Dos tramos parabólicos mantienen al personaje claramente por encima de los pinchos.
	tween.tween_property(player, "position", Vector2(500, 185), 0.48).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "position", Vector2(landing_x, 350), 0.48).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if repeat:
		tween.tween_property(player, "position", Vector2(180, 350), 0.0)
	return tween

func _pulse(node: Control) -> Tween:
	var tween := create_tween().set_loops(3)
	tween.tween_property(node, "scale", Vector2(1.12, 1.12), 0.18)
	tween.tween_property(node, "scale", Vector2.ONE, 0.18)
	return tween

func _progress_dots() -> String:
	var dots := ""
	for index in range(MESSAGES.size()):
		dots += "●" if index == _step else "○"
		dots += "  " if index < MESSAGES.size() - 1 else ""
	return dots

func _apply_visual_style() -> void:
	arena_frame.add_theme_stylebox_override("panel", _panel_style(Color("#171225e8"), Color("#c9a85b"), 4, 20))
	bottom_panel.add_theme_stylebox_override("panel", _panel_style(Color("#20162bf5"), Color("#e6c76f"), 3, 18))
	title_label.add_theme_color_override("font_shadow_color", Color("#08040d"))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	message_label.add_theme_color_override("font_color", Color("#fff8e8"))
	message_label.add_theme_color_override("font_shadow_color", Color("#10091a"))
	message_label.add_theme_constant_override("shadow_offset_x", 2)
	message_label.add_theme_constant_override("shadow_offset_y", 2)
	%SkipButton.add_theme_stylebox_override("normal", _panel_style(Color("#21172cdd"), Color("#8c73a5"), 2, 10))
	%SkipButton.add_theme_stylebox_override("hover", _panel_style(Color("#49335ff2"), Color("#e6c76f"), 2, 10))
	_style_navigation_buttons()

func _style_navigation_buttons() -> void:
	for button in [previous_button, next_button, start_button]:
		button.add_theme_color_override("font_color", Color("#fff8e8"))
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color("#ffe49a"))
		button.add_theme_color_override("font_disabled_color", Color("#cbc5d6"))
		button.add_theme_font_size_override("font_size", 32)

func _panel_style(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.02, 0.01, 0.04, 0.75)
	style.shadow_size = 12
	style.content_margin_left = 24.0
	style.content_margin_right = 24.0
	style.content_margin_top = 16.0
	style.content_margin_bottom = 16.0
	return style

func _start_mission() -> void:
	get_tree().change_scene_to_file(MISSION_SCENE)
