extends Control

const MISSION_SCENE := "res://scenes/mision_4_payasos/mapa_topos.tscn"
const CLOWN_NORMAL := preload("res://assets/assets_escena_payaso/pngtree-clown-icon-simple-style-png-image_15810983.png")
const CLOWN_HIT := preload("res://assets/assets_escena_payaso/payaso_golpeado.png")
const MESSAGES: Array[String] = [
	"Los payasos aparecerán por poco tiempo en distintos agujeros. ¡Mantente atento!",
	"Mueve el martillo con el mouse y haz clic sobre un payaso. En celular, tócalo directamente.",
	"Cada golpe acertado suma un punto. Golpea una sola vez a cada payaso antes de que se esconda.",
	"El ritmo aumentará poco a poco. Consigue suficientes puntos y mantén una buena precisión.",
	"¡Todo listo! Concéntrate, apunta con cuidado y rescata a tu mascota."
]

@onready var message_label: Label = %MessageLabel
@onready var step_label: Label = %StepLabel
@onready var previous_button: Button = %PreviousButton
@onready var next_button: Button = %NextButton
@onready var start_button: Button = %StartButton
@onready var clown: Control = %Clown
@onready var clown_sprite: TextureRect = %ClownSprite
@onready var hammer: Control = %Hammer
@onready var score: Label = %Score
@onready var speed_label: Label = %SpeedLabel
@onready var aim_hint: Label = %AimHint
@onready var arena_frame: Panel = %ArenaFrame
@onready var bottom_panel: PanelContainer = $Bottom
@onready var title_label: Label = $Title
@onready var holes: Array[Panel] = [%HoleLeft, %HoleCenter, %HoleRight]

var _step := 0
var _animation_token := 0
const STEP_END_DELAY := 0.3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
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
	var token := _animation_token
	message_label.text = MESSAGES[_step]
	step_label.text = "%s   PASO %d DE %d" % [_progress_dots(), _step + 1, MESSAGES.size()]
	previous_button.disabled = true
	next_button.visible = _step < MESSAGES.size() - 1
	start_button.visible = _step == MESSAGES.size() - 1
	next_button.disabled = true
	start_button.disabled = true
	_reset_demo()
	_play_demo(token)
	message_label.modulate.a = 0.0
	create_tween().tween_property(message_label, "modulate:a", 1.0, 0.18)

func _reset_demo() -> void:
	clown.position = Vector2(350, 180)
	clown.modulate = Color.WHITE
	clown_sprite.texture = CLOWN_NORMAL
	hammer.position = Vector2(700, 80)
	hammer.rotation = -0.35
	score.text = "Puntos: 0"
	speed_label.visible = false
	aim_hint.visible = false

func _play_demo(token: int) -> void:
	var tween: Tween
	match _step:
		0:
			tween = create_tween().set_loops(2)
			tween.tween_property(clown, "position:y", 105.0, 0.35).set_trans(Tween.TRANS_BACK)
			tween.tween_interval(0.4)
			tween.tween_property(clown, "position:y", 180.0, 0.25)
		1:
			aim_hint.visible = true
			tween = create_tween().set_loops(2)
			tween.tween_property(hammer, "position", Vector2(520, 185), 0.45)
			tween.tween_property(hammer, "rotation", 0.25, 0.14)
			tween.tween_property(hammer, "rotation", -0.35, 0.14)
		2:
			aim_hint.visible = true
			clown_sprite.texture = CLOWN_HIT
			score.text = "Puntos: 1 "
			tween = _pulse(score)
		3:
			score.text = "Puntos: 12"
			speed_label.visible = true
			tween = _pulse(speed_label)
		4:
			score.text = "Puntos: 40"
			tween = _pulse(clown)
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
	arena_frame.add_theme_stylebox_override("panel", _panel_style(Color("#241329e8"), Color("#efb84f"), 4, 22))
	bottom_panel.add_theme_stylebox_override("panel", _panel_style(Color("#2a152df5"), Color("#f2c45f"), 3, 18))
	title_label.add_theme_color_override("font_shadow_color", Color("#170617"))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	message_label.add_theme_color_override("font_color", Color("#fff8e8"))
	message_label.add_theme_color_override("font_shadow_color", Color("#170617"))
	message_label.add_theme_constant_override("shadow_offset_x", 2)
	message_label.add_theme_constant_override("shadow_offset_y", 2)
	%SkipButton.add_theme_stylebox_override("normal", _panel_style(Color("#30182edd"), Color("#aa728e"), 2, 10))
	%SkipButton.add_theme_stylebox_override("hover", _panel_style(Color("#633057f2"), Color("#f2c45f"), 2, 10))
	_style_navigation_buttons()
	for hole in holes:
		hole.add_theme_stylebox_override("panel", _hole_style())

func _style_navigation_buttons() -> void:
	for button in [previous_button, next_button, start_button]:
		button.add_theme_color_override("font_color", Color("#fff8e8"))
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color("#ffe49a"))
		button.add_theme_color_override("font_disabled_color", Color("#d4c3d1"))
		button.add_theme_font_size_override("font_size", 32)

func _panel_style(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.06, 0.01, 0.05, 0.78)
	style.shadow_size = 12
	style.content_margin_left = 24.0
	style.content_margin_right = 24.0
	style.content_margin_top = 16.0
	style.content_margin_bottom = 16.0
	return style

func _hole_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0c0610")
	style.border_color = Color("#5f365d")
	style.border_width_top = 5
	style.set_corner_radius_all(50)
	style.shadow_color = Color(0, 0, 0, 0.8)
	style.shadow_size = 8
	return style

func _start_mission() -> void:
	get_tree().change_scene_to_file(MISSION_SCENE)
