extends Node2D

@onready var ui: Minijuego1TutorialUI = $TutorialUI
@onready var demo: Minijuego1TutorialDemo = $DemoWorld
@onready var dark_overlay: ColorRect = $TutorialUI/Overlay/DarkOverlay

const STEP_INTRO := 0
const STEP_MOVE_RIGHT := 1
const STEP_MOVE_LEFT := 2
const STEP_MOVE_UP := 3
const STEP_MOVE_DOWN := 4
const STEP_ALEGRIA := 5
const STEP_TRISTEZA := 6
const STEP_ENOJO := 7
const STEP_DESAGRADO := 8
const STEP_SORPRESA := 9
const STEP_OBSTACLE := 10
const STEP_CLOSURE := 11
const STEP_COUNT := 12

const STEP_LOOP_DELAY := 1.1
const STEP_END_DELAY := 0.3
const ESCENA_FALLBACK_MINIJUEGO_1 := "res://scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn"

var _current_step: int = STEP_INTRO
var _playback_token: int = 0
var _completed_steps_once: Dictionary = {}

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

	demo.reset_world()
	ui.reset_keys()
	ui.show_keys(false)
	ui.set_step_indicator(_current_step, STEP_COUNT)
	ui.set_navigation(_current_step, STEP_COUNT, _current_step == STEP_CLOSURE)
	ui.set_continue_enabled(false)
	dark_overlay.color = Color(0, 0, 0, 0.35)

	match _current_step:
		STEP_INTRO:
			await _play_intro(token)
		STEP_MOVE_RIGHT:
			await _play_looped_step(token, _current_step, _play_move_right)
		STEP_MOVE_LEFT:
			await _play_looped_step(token, _current_step, _play_move_left)
		STEP_MOVE_UP:
			await _play_looped_step(token, _current_step, _play_move_up)
		STEP_MOVE_DOWN:
			await _play_looped_step(token, _current_step, _play_move_down)
		STEP_ALEGRIA:
			await _play_looped_step(token, _current_step, _play_alegria)
		STEP_TRISTEZA:
			await _play_looped_step(token, _current_step, _play_tristeza)
		STEP_ENOJO:
			await _play_looped_step(token, _current_step, _play_enojo)
		STEP_DESAGRADO:
			await _play_looped_step(token, _current_step, _play_desagrado)
		STEP_SORPRESA:
			await _play_looped_step(token, _current_step, _play_sorpresa)
		STEP_OBSTACLE:
			await _play_looped_step(token, _current_step, _play_obstacle)
		STEP_CLOSURE:
			_play_closure(token)

func _is_token_valid(token: int) -> bool:
	return token == _playback_token

func _has_completed_step_once(step: int) -> bool:
	return _completed_steps_once.get(step, false)

func _mark_step_completed_once(step: int) -> void:
	_completed_steps_once[step] = true

func _play_intro(token: int) -> void:
	ui.set_message("En esta misión capturarás emociones; cada una altera tus controles de forma distinta.")
	if not _is_token_valid(token):
		return
	await get_tree().create_timer(0.6).timeout
	if _is_token_valid(token):
		ui.set_continue_enabled(true)

func _play_looped_step(token: int, step_id: int, callback: Callable) -> void:
	# Cada visita reproduce la demostración completa antes de permitir avanzar.
	var should_block_next_first_run := true
	while _is_token_valid(token):
		demo.reset_world()
		if should_block_next_first_run:
			ui.set_continue_enabled(false)
		await callback.call(token)
		if not _is_token_valid(token):
			return

		if should_block_next_first_run:
			_mark_step_completed_once(step_id)
			await get_tree().create_timer(STEP_END_DELAY).timeout
			if not _is_token_valid(token):
				return
			ui.set_continue_enabled(true)
			should_block_next_first_run = false

		await get_tree().create_timer(STEP_LOOP_DELAY).timeout

func _play_movement_example(token: int, key: String, offset: Vector2, text: String) -> void:
	ui.show_keys(true)
	ui.set_message(text)
	ui.animate_key(key)
	if not _is_token_valid(token):
		return
	await demo.move_player(offset, 0.45).finished
	if _is_token_valid(token):
		ui.reset_keys()

func _play_move_right(token: int) -> void:
	await _play_movement_example(token, "D", Vector2(110, 0), "Para moverte a la derecha se usa la tecla D.")

func _play_move_left(token: int) -> void:
	await _play_movement_example(token, "A", Vector2(-110, 0), "Para moverte a la izquierda se usa la tecla A.")

func _play_move_up(token: int) -> void:
	await _play_movement_example(token, "W", Vector2(0, -95), "Para moverte hacia arriba se usa la tecla W.")

func _play_move_down(token: int) -> void:
	await _play_movement_example(token, "S", Vector2(0, 95), "Para moverte hacia abajo se usa la tecla S.")

func _play_alegria(token: int) -> void:
	ui.show_keys(false)
	ui.set_message("Alegría: te da un impulso y te permite avanzar más rápido.")
	demo.show_emotion("alegria")
	if not _is_token_valid(token):
		return
	await demo.move_player(Vector2(260, -35), 0.8).finished
	if not _is_token_valid(token):
		return
	await demo.play_emotion_capture_effect().finished
	if not _is_token_valid(token):
		return
	await demo.move_player(Vector2(200, 0), 0.32).finished

func _play_tristeza(token: int) -> void:
	ui.show_keys(false)
	ui.set_message("Tristeza: reduce tu velocidad, así que te costará más avanzar.")
	demo.show_emotion("tristeza")
	if not _is_token_valid(token):
		return
	await demo.move_player(Vector2(260, -35), 0.8).finished
	if not _is_token_valid(token):
		return
	await demo.play_emotion_capture_effect().finished
	if not _is_token_valid(token):
		return
	await demo.move_player(Vector2(120, 0), 0.95).finished

func _play_enojo(token: int) -> void:
	ui.show_keys(true)
	ui.set_message("Enojo invierte tus controles: antes de recogerlo, D te mueve a la derecha; después de recogerlo, la misma tecla D te mueve a la izquierda.")
	demo.show_emotion("enojo")
	ui.animate_key("D")
	if not _is_token_valid(token):
		return
	await demo.move_player(Vector2(240, 0), 0.75).finished
	if not _is_token_valid(token):
		return
	await demo.play_emotion_capture_effect().finished
	if not _is_token_valid(token):
		return
	await get_tree().create_timer(0.15).timeout
	ui.animate_key("D")
	await demo.move_player(Vector2(-170, 0), 0.6).finished
	ui.reset_keys()

func _play_desagrado(token: int) -> void:
	ui.show_keys(false)
	ui.set_message("Desagrado: te congela por momentos, así que avanzar no será continuo.")
	demo.show_emotion("desagrado")
	if not _is_token_valid(token):
		return
	await demo.move_player(Vector2(250, -30), 0.85).finished
	if not _is_token_valid(token):
		return
	await demo.play_emotion_capture_effect().finished
	if not _is_token_valid(token):
		return
	await demo.move_player(Vector2(90, 0), 0.28).finished
	if not _is_token_valid(token):
		return
	await get_tree().create_timer(0.55).timeout
	if not _is_token_valid(token):
		return
	await demo.move_player(Vector2(90, 0), 0.28).finished

func _play_sorpresa(token: int) -> void:
	ui.show_keys(false)
	ui.set_message("Sorpresa: te da el impulso más veloz para reaccionar ante lo inesperado.")
	demo.show_emotion("sorpresa")
	if not _is_token_valid(token):
		return
	await demo.move_player(Vector2(260, -35), 0.8).finished
	if not _is_token_valid(token):
		return
	await demo.play_emotion_capture_effect().finished
	if not _is_token_valid(token):
		return
	await demo.move_player(Vector2(230, 0), 0.3).finished

func _play_obstacle(token: int) -> void:
	ui.show_keys(false)
	ui.set_message("Evita los enemigos: cada choque te quita una vida en la misión real.")
	demo.show_obstacle()
	if not _is_token_valid(token):
		return
	await demo.move_player(Vector2(265, 0), 0.7).finished
	if not _is_token_valid(token):
		return
	await demo.play_obstacle_hit_effect().finished

func _play_closure(token: int) -> void:
	ui.show_keys(false)
	ui.set_message("¡Listo! Ya conoces cómo moverte y qué hace cada emoción.")
	dark_overlay.color = Color(0, 0, 0, 0.42)
	ui.set_continue_enabled(false)
	if not _is_token_valid(token):
		return

func _start_real_mission() -> void:
	var escena_destino: String = GameManager.obtener_siguiente_mapa_minijuego_1()
	if escena_destino.is_empty():
		escena_destino = ESCENA_FALLBACK_MINIJUEGO_1
	get_tree().change_scene_to_file(escena_destino)
