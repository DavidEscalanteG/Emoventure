extends Control

@onready var label: DialogueLabel = %DialogueLabel
@onready var type_sound: AudioStreamPlayer = $DialogueTypeSound
@onready var type_timer: Timer = $TypeSoundTimer
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu
@onready var character_label = %CharacterLabel

var dialogue_resource: DialogueResource
var current_line: DialogueLine
var visible_chars := 0
var line_finished := false


signal dialogue_finished

func _ready():
	label.bbcode_enabled = true
	type_timer.timeout.connect(_on_type_tick)

	responses_menu.response_selected.connect(_on_response_selected)
	responses_menu.hide()

func start_dialogue(resource: DialogueResource):
	dialogue_resource = resource
	current_line = await DialogueManager.get_next_dialogue_line(dialogue_resource)
	_show_line()

func _show_line():

	if current_line.character != "":
		character_label.text = current_line.character
		character_label.show()
		match current_line.character:
			"Carlos":
				type_sound.pitch_scale = 1.0
				character_label.modulate = Color.WHITE
			"Gitana":
				type_sound.pitch_scale = 0.85
				character_label.modulate = Color.CRIMSON

	else:
		character_label.hide()

	label.text = current_line.text
	label.visible_characters = 0
	visible_chars = 0
	line_finished = false

	responses_menu.hide()
	type_timer.start()


func _on_type_tick():
	visible_chars += 1
	label.visible_characters = visible_chars

	type_sound.pitch_scale = randf_range(0.95, 1.05)
	type_sound.play()

	if visible_chars >= label.text.length():
		type_timer.stop()
		type_sound.stop()
		line_finished = true

		# 👇 Si hay respuestas, mostramos el menú
		if current_line.responses.size() > 0:
			_show_responses()

func _show_responses():
	responses_menu.show()
	responses_menu.responses = current_line.responses
	#responses_menu.grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		_handle_advance()

func _gui_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		_handle_advance()

func _handle_advance():
	# ⛔ Si hay respuestas visibles, el menú controla el input
	if responses_menu.visible:
		return

	if not line_finished:
		label.visible_characters = -1
		type_timer.stop()
		type_sound.stop()
		line_finished = true
	else:
		current_line = await DialogueManager.get_next_dialogue_line(
			dialogue_resource,
			current_line.next_id
		)

		if current_line:
			_show_line()
		else:
			hide()
			emit_signal("dialogue_finished")


func _on_response_selected(response):
	responses_menu.hide()

	current_line = await DialogueManager.get_next_dialogue_line(
		dialogue_resource,
		response.next_id
	)

	if current_line:
		_show_line()
	else:
		hide()
		emit_signal("dialogue_finished")
