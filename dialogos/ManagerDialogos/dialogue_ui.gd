extends Control

@onready var label = %DialogueLabel
@onready var type_sound: AudioStreamPlayer = $DialogueTypeSound
@onready var type_timer: Timer = $TypeSoundTimer
@onready var responses_menu = %ResponsesMenu
@onready var character_label: RichTextLabel = %CharacterLabel

var dialogue_resource
var current_line
var visible_chars: int = 0
var line_finished: bool = false


signal dialogo_finalizado

func _ready() -> void:
	label.bbcode_enabled = true
	type_timer.timeout.connect(_al_tictac_tipeo)

	responses_menu.response_selected.connect(_al_respuesta_seleccionada)
	responses_menu.hide()


func _get_dialogue_manager() -> Object:
	if Engine.has_singleton("DialogueManager"):
		return Engine.get_singleton("DialogueManager")
	return null


func _pedir_siguiente_linea(next_id: String = ""):
	var dialogue_manager := _get_dialogue_manager()
	if dialogue_manager == null:
		push_error("DialogueManager no está disponible.")
		return null

	if next_id == "":
		return await dialogue_manager.get_next_dialogue_line(dialogue_resource)

	return await dialogue_manager.get_next_dialogue_line(dialogue_resource, next_id)




func _cinematica_activa() -> bool:
	if not Engine.has_singleton("DialogueActors"):
		return false

	var dialogue_actors := Engine.get_singleton("DialogueActors")
	if dialogue_actors == null:
		return false

	return bool(dialogue_actors.get("cinematica_activa"))

func iniciar_dialogo(resource) -> void:
	dialogue_resource = resource
	current_line = await _pedir_siguiente_linea()
	if current_line == null:
		return
	_mostrar_linea()


func _mostrar_linea() -> void:
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


func _al_tictac_tipeo() -> void:
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
			_mostrar_respuestas()


func _mostrar_respuestas() -> void:
	responses_menu.show()
	responses_menu.responses = current_line.responses
	#responses_menu.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _cinematica_activa():
		return

	if event.is_action_pressed("ui_accept"):
		_gestionar_avance()


func _gui_input(event: InputEvent) -> void:
	if _cinematica_activa():
		return

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		_gestionar_avance()


func _gestionar_avance() -> void:
	if _cinematica_activa():
		return

	if responses_menu.visible:
		return

	if not line_finished:
		label.visible_characters = -1
		type_timer.stop()
		type_sound.stop()
		line_finished = true
	else:
		current_line = await _pedir_siguiente_linea(current_line.next_id)

		if current_line:
			_mostrar_linea()
		else:
			hide()
			emit_signal("dialogo_finalizado")


func _al_respuesta_seleccionada(response: Variant) -> void:
	# Dialogue Manager provee un objeto de respuesta dinámico (Variant) con `next_id`.
	# Se mantiene Variant para compatibilidad con la API del plugin.
	responses_menu.hide()

	current_line = await _pedir_siguiente_linea(str(response.next_id))

	if current_line:
		_mostrar_linea()
	else:
		hide()
		emit_signal("dialogo_finalizado")
