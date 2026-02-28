extends Node2D

# Controlador principal del tutorial. Implementa una máquina de estados por pasos.
# Cada vez que se navega hacia adelante o atrás se restaura el estado visual base
# y luego se ejecuta únicamente la demostración del paso seleccionado.

@onready var ui: Minijuego1TutorialUI = $TutorialUI
@onready var demo: Minijuego1TutorialDemo = $DemoWorld
@onready var dark_overlay: ColorRect = $TutorialUI/Overlay/DarkOverlay

const STEP_INTRO := 0
const STEP_MOVEMENT := 1
const STEP_CAPTURE := 2
const STEP_OBSTACLE := 3
const STEP_CLOSURE := 4
const STEP_COUNT := 5

var _current_step: int = STEP_INTRO
var _playback_token: int = 0

const ESCENA_FALLBACK_MINIJUEGO_1 := "res://scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn"

func _ready() -> void:
	ui.previous_pressed.connect(_on_previous_pressed)
	ui.next_pressed.connect(_on_next_pressed)
	ui.skip_pressed.connect(_start_real_mission)
	ui.start_pressed.connect(_start_real_mission)
	_go_to_step(STEP_INTRO)

func _on_previous_pressed() -> void:
	_go_to_step(_current_step - 1)

func _on_next_pressed() -> void:
	_go_to_step(_current_step + 1)

func _go_to_step(step: int) -> void:
	_current_step = clampi(step, 0, STEP_COUNT - 1)
	_playback_token += 1
	var token := _playback_token

	# Restauración total para garantizar retroceso limpio.
	demo.reset_world()
	ui.reset_keys()
	ui.show_keys(false)
	ui.set_navigation(_current_step, STEP_COUNT, _current_step == STEP_CLOSURE)
	dark_overlay.color = Color(0, 0, 0, 0.35)

	match _current_step:
		STEP_INTRO:
			await _play_intro(token)
		STEP_MOVEMENT:
			await _play_movement(token)
		STEP_CAPTURE:
			await _play_capture(token)
		STEP_OBSTACLE:
			await _play_obstacle(token)
		STEP_CLOSURE:
			_play_closure(token)

func _is_token_valid(token: int) -> bool:
	return token == _playback_token

func _play_intro(token: int) -> void:
	ui.set_message("En esta misión deberás capturar tus emociones.\nCada emoción cambia tu forma de moverte.")
	if not _is_token_valid(token):
		return
	await get_tree().create_timer(0.15).timeout

func _play_movement(token: int) -> void:
	ui.show_keys(true)
	var sequence := [
		{"key": "D", "offset": Vector2(110, 0), "text": "Para moverte a la derecha se usa la tecla D."},
		{"key": "A", "offset": Vector2(-110, 0), "text": "Para moverte a la izquierda se usa la tecla A."},
		{"key": "W", "offset": Vector2(0, -95), "text": "Para moverte hacia arriba se usa la tecla W."},
		{"key": "S", "offset": Vector2(0, 95), "text": "Para moverte hacia abajo se usa la tecla S."},
	]

	for item in sequence:
		if not _is_token_valid(token):
			return
		ui.set_message(item.text)
		ui.animate_key(item.key)
		var tween := demo.move_player(item.offset, 0.45)
		await tween.finished
		if not _is_token_valid(token):
			return
		await get_tree().create_timer(0.2).timeout

	if _is_token_valid(token):
		ui.reset_keys()

func _play_capture(token: int) -> void:
	ui.set_message("La alegría te hace avanzar más rápido.")
	demo.show_emotion()
	ui.show_keys(false)
	if not _is_token_valid(token):
		return

	var move_tween := demo.move_player(Vector2(410, -60), 0.9)
	await move_tween.finished
	if not _is_token_valid(token):
		return

	demo.play_emotion_capture_effect()
	await get_tree().create_timer(0.3).timeout
	if not _is_token_valid(token):
		return

	var speed_tween := demo.move_player(Vector2(180, 0), 0.4)
	await speed_tween.finished

func _play_obstacle(token: int) -> void:
	ui.set_message("Evita los obstáculos. En el juego real tendrás 3 oportunidades.")
	demo.show_obstacle()
	if not _is_token_valid(token):
		return

	var move_tween := demo.move_player(Vector2(265, 0), 0.7)
	await move_tween.finished
	if not _is_token_valid(token):
		return

	demo.play_obstacle_hit_effect()
	await get_tree().create_timer(0.35).timeout

func _play_closure(token: int) -> void:
	ui.show_keys(false)
	ui.set_message("Ahora estás listo para comenzar.")
	dark_overlay.color = Color(0, 0, 0, 0.42)
	if not _is_token_valid(token):
		return

func _start_real_mission() -> void:
	var escena_destino: String = GameManager.obtener_siguiente_mapa_minijuego_1()
	if escena_destino.is_empty():
		escena_destino = ESCENA_FALLBACK_MINIJUEGO_1
	get_tree().change_scene_to_file(escena_destino)
