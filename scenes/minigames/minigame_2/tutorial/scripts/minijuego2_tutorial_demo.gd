extends Control
class_name Minijuego2TutorialDemo

const TOTAL_FOTOS := 7

@onready var photos_grid: GridContainer = $PhotosGrid
@onready var emotion_panel: PanelContainer = $EmotionPanel
@onready var emotions_grid: GridContainer = $EmotionPanel/MarginContainer/VBoxContainer/EmotionsGrid
@onready var accept_button: Button = $EmotionPanel/MarginContainer/VBoxContainer/AcceptButton
@onready var progress_bar: ProgressBar = $TopInfo/MarginContainer/VBoxContainer/ProgressBar
@onready var progress_label: Label = $TopInfo/MarginContainer/VBoxContainer/ProgressLabel

var _photo_frames: Array[PanelContainer] = []
var _photo_highlights: Array[ColorRect] = []
var _photo_checks: Array[Label] = []
var _emotion_buttons: Array[Button] = []

func _ready() -> void:
	for child in photos_grid.get_children():
		var frame := child as PanelContainer
		if frame == null:
			continue
		_photo_frames.append(frame)
		_photo_highlights.append(frame.get_node("Highlight") as ColorRect)
		_photo_checks.append(frame.get_node("Check") as Label)

	for child in emotions_grid.get_children():
		var button := child as Button
		if button != null:
			_emotion_buttons.append(button)

	reset_visual_state()

func reset_visual_state() -> void:
	for index in range(_photo_frames.size()):
		var frame := _photo_frames[index]
		frame.modulate = Color(1, 1, 1, 0.85)
		_photo_highlights[index].visible = false
		_photo_checks[index].visible = false

	for button in _emotion_buttons:
		button.modulate = Color(1, 1, 1, 0.9)
		button.disabled = true

	emotion_panel.visible = false
	accept_button.modulate = Color(1, 1, 1, 0.9)
	accept_button.disabled = true
	set_progress(0)

func show_photos_as_disabled() -> void:
	for frame in _photo_frames:
		frame.modulate = Color(1, 1, 1, 0.7)

func highlight_photo(index: int) -> void:
	if not _is_photo_index_valid(index):
		return

	_photo_highlights[index].visible = true
	_photo_frames[index].modulate = Color(1, 1, 1, 1.0)

func pulse_photo(index: int) -> Tween:
	if not _is_photo_index_valid(index):
		return create_tween()

	var frame := _photo_frames[index]
	var tween := create_tween()
	tween.tween_property(frame, "scale", Vector2(0.96, 0.96), 0.1)
	tween.tween_property(frame, "scale", Vector2.ONE, 0.14)
	return tween

func show_emotion_panel() -> void:
	emotion_panel.visible = true

func highlight_emotion(button_index: int) -> void:
	for i in range(_emotion_buttons.size()):
		_emotion_buttons[i].modulate = Color(1, 1, 1, 0.85)

	if button_index < 0 or button_index >= _emotion_buttons.size():
		return

	_emotion_buttons[button_index].modulate = Color(1.0, 1.0, 0.6, 1.0)

func pulse_emotion(button_index: int) -> Tween:
	if button_index < 0 or button_index >= _emotion_buttons.size():
		return create_tween()

	var button := _emotion_buttons[button_index]
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(1.04, 1.04), 0.1)
	tween.tween_property(button, "scale", Vector2.ONE, 0.14)
	return tween

func highlight_accept_button() -> void:
	accept_button.modulate = Color(1.0, 1.0, 0.6, 1.0)

func pulse_accept_button() -> Tween:
	var tween := create_tween()
	tween.tween_property(accept_button, "scale", Vector2(0.96, 0.96), 0.08)
	tween.tween_property(accept_button, "scale", Vector2.ONE, 0.12)
	return tween

func mark_photo_completed(index: int) -> void:
	if not _is_photo_index_valid(index):
		return

	_photo_checks[index].visible = true
	_photo_frames[index].modulate = Color(0.7, 1.0, 0.7, 1.0)
	_photo_highlights[index].visible = false

func set_progress(completed_photos: int) -> void:
	var clamped := clampi(completed_photos, 0, TOTAL_FOTOS)
	progress_bar.max_value = TOTAL_FOTOS
	progress_bar.value = clamped
	progress_label.text = "%d / %d cuadros completados" % [clamped, TOTAL_FOTOS]

func _is_photo_index_valid(index: int) -> bool:
	return index >= 0 and index < _photo_frames.size()
