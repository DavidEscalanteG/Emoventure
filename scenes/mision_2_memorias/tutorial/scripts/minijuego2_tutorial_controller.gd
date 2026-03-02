extends Control

# Controlador del tutorial: máquina de estados por pasos.
# Regla principal: al navegar entre pasos, siempre restaurar el estado visual base
# para garantizar retroceso limpio y evitar contaminación de estado.

@onready var ui: Minijuego2TutorialUI = $TutorialUI
@onready var demo: Minijuego2TutorialDemo = $TutorialDemo

@export_file("*.tscn") var mission_scene_path: String = "res://scenes/mision_2_memorias/mision_2_memorias.tscn"

const STEP_INTRO := 0
const STEP_SELECT_PHOTO := 1
const STEP_SELECT_EMOTION := 2
const STEP_CONFIRM := 3
const STEP_PROGRESS := 4
const STEP_CLOSURE := 5
const STEP_COUNT := 6

const PHOTO_INDEX_DEMO := 2
const EMOTION_INDEX_DEMO := 0

var _current_step: int = STEP_INTRO
var _playback_token: int = 0
var _completed_steps_once: Dictionary = {}

func _ready() -> void:
	ui.previous_pressed.connect(_on_previous_pressed)
	ui.next_pressed.connect(_on_next_pressed)
	ui.start_pressed.connect(_start_real_mission)
	ui.skip_pressed.connect(_start_real_mission)
	_go_to_step(STEP_INTRO)

func _on_previous_pressed() -> void:
	_go_to_step(_current_step - 1)

func _on_next_pressed() -> void:
	_go_to_step(_current_step + 1)

func _go_to_step(step: int) -> void:
	_current_step = clampi(step, 0, STEP_COUNT - 1)
	_playback_token += 1
	var token := _playback_token

	# Restauración total antes de reproducir cada paso.
	demo.reset_visual_state()
	ui.set_step_indicator(_current_step, STEP_COUNT)
	ui.set_navigation(_current_step, STEP_COUNT, _current_step == STEP_CLOSURE)
	ui.set_continue_enabled(_can_continue_step(_current_step))
	ui.set_overlay_alpha(0.30)

	match _current_step:
		STEP_INTRO:
			await _play_intro(token)
		STEP_SELECT_PHOTO:
			await _play_select_photo(token)
		STEP_SELECT_EMOTION:
			await _play_select_emotion(token)
		STEP_CONFIRM:
			await _play_confirm(token)
		STEP_PROGRESS:
			await _play_progress(token)
		STEP_CLOSURE:
			_play_closure(token)

func _is_token_valid(token: int) -> bool:
	return token == _playback_token

func _has_completed_step_once(step: int) -> bool:
	return _completed_steps_once.get(step, false)

func _mark_step_completed_once(step: int) -> void:
	_completed_steps_once[step] = true

func _can_continue_step(step: int) -> bool:
	return _is_step_unlocked_for_continue(step) or _has_completed_step_once(step)

func _is_step_unlocked_for_continue(step: int) -> bool:
	return step == STEP_INTRO or step == STEP_CLOSURE

func _play_intro(token: int) -> void:
	demo.show_photos_as_disabled()
	ui.set_message(
		"En esta misión explorarás tus recuerdos.\n"
		+ "Deberás identificar qué emoción sientes en cada imagen."
	)
	if not _is_token_valid(token):
		return
	await get_tree().create_timer(0.15).timeout

func _play_select_photo(token: int) -> void:
	demo.show_photos_as_disabled()
	demo.highlight_photo(PHOTO_INDEX_DEMO)
	ui.set_message("Primero selecciona una fotografía.")
	if not _is_token_valid(token):
		return

	ui.set_continue_enabled(_has_completed_step_once(STEP_SELECT_PHOTO))

	var tween := demo.pulse_photo(PHOTO_INDEX_DEMO)
	await tween.finished
	if not _is_token_valid(token):
		return

	_mark_step_completed_once(STEP_SELECT_PHOTO)
	ui.set_continue_enabled(true)

func _play_select_emotion(token: int) -> void:
	demo.show_photos_as_disabled()
	demo.highlight_photo(PHOTO_INDEX_DEMO)
	demo.show_emotion_panel()
	demo.highlight_emotion(EMOTION_INDEX_DEMO)
	ui.set_message(
		"No hay respuestas correctas o incorrectas.\n"
		+ "Cada emoción depende de tu experiencia personal."
	)
	if not _is_token_valid(token):
		return

	ui.set_continue_enabled(_has_completed_step_once(STEP_SELECT_EMOTION))

	var tween := demo.pulse_emotion(EMOTION_INDEX_DEMO)
	await tween.finished
	if not _is_token_valid(token):
		return

	_mark_step_completed_once(STEP_SELECT_EMOTION)
	ui.set_continue_enabled(true)

func _play_confirm(token: int) -> void:
	demo.show_photos_as_disabled()
	demo.highlight_photo(PHOTO_INDEX_DEMO)
	demo.show_emotion_panel()
	demo.highlight_emotion(EMOTION_INDEX_DEMO)
	demo.highlight_accept_button()
	ui.set_message("Debes completar los 7 cuadros para terminar la misión.")
	if not _is_token_valid(token):
		return

	ui.set_continue_enabled(_has_completed_step_once(STEP_CONFIRM))

	var tween := demo.pulse_accept_button()
	await tween.finished
	if not _is_token_valid(token):
		return

	demo.mark_photo_completed(PHOTO_INDEX_DEMO)
	demo.set_progress(1)
	_mark_step_completed_once(STEP_CONFIRM)
	ui.set_continue_enabled(true)

func _play_progress(token: int) -> void:
	demo.show_photos_as_disabled()
	demo.show_emotion_panel()
	demo.mark_photo_completed(PHOTO_INDEX_DEMO)
	demo.set_progress(1)
	ui.set_message("Aquí puedes ver cómo el progreso avanza hasta completar todos los cuadros.")
	if not _is_token_valid(token):
		return

	ui.set_continue_enabled(_has_completed_step_once(STEP_PROGRESS))

	for index in range(Minijuego2TutorialDemo.TOTAL_FOTOS):
		if not _is_token_valid(token):
			return
		demo.highlight_photo(index)
		var tween := demo.pulse_photo(index)
		await tween.finished
		demo.mark_photo_completed(index)
		demo.set_progress(index + 1)
		await get_tree().create_timer(0.08).timeout

	if not _is_token_valid(token):
		return

	_mark_step_completed_once(STEP_PROGRESS)
	ui.set_continue_enabled(true)

func _play_closure(token: int) -> void:
	demo.show_photos_as_disabled()
	for index in range(Minijuego2TutorialDemo.TOTAL_FOTOS):
		demo.mark_photo_completed(index)
	demo.set_progress(Minijuego2TutorialDemo.TOTAL_FOTOS)
	ui.set_overlay_alpha(0.36)
	ui.set_message("Estás listo para comenzar.\nReconoce tus emociones con honestidad.")
	if not _is_token_valid(token):
		return

func _start_real_mission() -> void:
	if mission_scene_path.is_empty():
		push_warning("mission_scene_path no configurado en Minijuego2_Tutorial")
		return

	get_tree().change_scene_to_file(mission_scene_path)
