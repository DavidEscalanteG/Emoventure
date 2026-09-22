extends Control
class_name Minijuego2TutorialDemo

const TOTAL_FOTOS := 7

const PHOTO_TEXTURES: Array[Texture2D] = [
	preload("res://assets/assets_escena_9/Memorias/blanco_y_negro/CuadroMemoria1ByN.jpg"),
	preload("res://assets/assets_escena_9/Memorias/blanco_y_negro/CuadroMemoria2ByN.jpg"),
	preload("res://assets/assets_escena_9/Memorias/blanco_y_negro/CuadroMemoria3ByN.png"),
	preload("res://assets/assets_escena_9/Memorias/blanco_y_negro/CuadroMemoria4ByN.png"),
	preload("res://assets/assets_escena_9/Memorias/blanco_y_negro/CuadroMemoria5ByN.jpg"),
	preload("res://assets/assets_escena_9/Memorias/blanco_y_negro/CuadroMemoria6ByN.jpg"),
	preload("res://assets/assets_escena_9/Memorias/blanco_y_negro/CuadroMemoria7ByN.jpg"),
]

const EMOTION_COLORS: Array[Color] = [
	Color("#f6cf55"), Color("#73a9e6"), Color("#e76262"), Color("#b690e8"),
	Color("#e889cf"), Color("#8fcf7a"), Color("#ef8eaa"),
]

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
		_decorate_photo(frame, _photo_frames.size() - 1)

	for child in emotions_grid.get_children():
		var button := child as Button
		if button != null:
			_emotion_buttons.append(button)
			_decorate_emotion_button(button, _emotion_buttons.size() - 1)

	_apply_panel_styles()

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

func _decorate_photo(frame: PanelContainer, index: int) -> void:
	var color_block := frame.get_node_or_null("Color") as ColorRect
	if color_block != null:
		color_block.color = Color("#171221")
	var old_label := frame.get_node_or_null("Label") as Label
	if old_label != null:
		old_label.visible = false

	var photo := TextureRect.new()
	photo.name = "MemoryImage"
	photo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	photo.texture = PHOTO_TEXTURES[index]
	photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.add_child(photo)
	frame.move_child(photo, 1)

	var style := StyleBoxFlat.new()
	style.bg_color = Color("#171221")
	style.border_color = Color("#bc9860")
	style.set_border_width_all(5)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0.04, 0.01, 0.08, 0.8)
	style.shadow_size = 8
	frame.add_theme_stylebox_override("panel", style)
	_photo_checks[index].add_theme_color_override("font_color", Color("#efffbc"))
	_photo_checks[index].add_theme_color_override("font_outline_color", Color("#173b26"))
	_photo_checks[index].add_theme_constant_override("outline_size", 8)

func _decorate_emotion_button(button: Button, index: int) -> void:
	var accent := EMOTION_COLORS[index]
	for state in ["normal", "disabled", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(accent, 0.82 if state != "disabled" else 0.58)
		style.border_color = accent.lightened(0.25)
		style.set_border_width_all(2)
		style.set_corner_radius_all(8)
		button.add_theme_stylebox_override(state, style)
	button.add_theme_color_override("font_color", Color("#201529"))
	button.add_theme_color_override("font_disabled_color", Color("#201529"))
	button.add_theme_font_size_override("font_size", 18)

func _apply_panel_styles() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#251a38ee")
	panel_style.border_color = Color("#dfbd70")
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(14)
	panel_style.shadow_color = Color(0.03, 0.01, 0.07, 0.75)
	panel_style.shadow_size = 8
	emotion_panel.add_theme_stylebox_override("panel", panel_style)
	$TopInfo.add_theme_stylebox_override("panel", panel_style.duplicate())
	progress_bar.add_theme_color_override("font_color", Color.TRANSPARENT)
	progress_label.add_theme_color_override("font_color", Color("#fff1c5"))
