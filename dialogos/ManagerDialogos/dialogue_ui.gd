extends Control

@onready var label: DialogueLabel = %DialogueLabel
@onready var type_sound: AudioStreamPlayer = $DialogueTypeSound
@onready var type_timer: Timer = $TypeSoundTimer
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu
@onready var character_label: RichTextLabel = %CharacterLabel

var dialogue_resource: DialogueResource
var current_line: DialogueLine
var visible_chars: int = 0
var line_finished: bool = false


signal dialogo_finalizado

func _ready() -> void:
	label.bbcode_enabled = true
	type_timer.timeout.connect(_al_tictac_tipeo)

	responses_menu.response_selected.connect(_al_respuesta_seleccionada)
	responses_menu.hide()

func iniciar_dialogo(resource: DialogueResource) -> void:
	# Cada diálogo empieza con un estado limpio. Esto permite reanudar una partida
	# aunque la escena anterior se haya cerrado durante una acción cinemática.
	DialogueActors.reiniciar_estado_cinematica()
	dialogue_resource = resource
	current_line = await DialogueManager.get_next_dialogue_line(dialogue_resource)
	_mostrar_linea()

func _mostrar_linea() -> void:

	if current_line.character != "":
		character_label.text = current_line.character
		character_label.show()
		match current_line.character:
			"Gitana":
				type_sound.pitch_scale = 0.85
				character_label.modulate = Color.CRIMSON
			"???":
				type_sound.pitch_scale = 0.85
				character_label.modulate = Color.CRIMSON
			"Mujer Lagarto":
				type_sound.pitch_scale = 1.0
				character_label.modulate = Color.YELLOW
			"{{DatosJugador.nombre_mascota}}":
				# La mascota suena un poco más aguda
				type_sound.pitch_scale = 1.2 
				character_label.modulate = Color.PINK
			"Frankenstein":
				# Voz lenta y muy grave
				type_sound.pitch_scale = 0.6 
				character_label.modulate = Color.DARK_GREEN
			"Narrador":
				type_sound.pitch_scale = 1.0
				character_label.modulate = Color.PURPLE
			"Domador":
				type_sound.pitch_scale = 0.95
				character_label.modulate = Color.ORANGE
			"Parca":
				# Voz casi de ultratumba
				type_sound.pitch_scale = 0.5 
				character_label.modulate = Color.DARK_GRAY
			_: # Para cualquier otro personaje que no esté en la lista
				type_sound.pitch_scale = 1.0
				character_label.modulate = Color.WHITE

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
	
	if DialogueActors.cinematica_activa:
		return
		
	if event.is_action_pressed("ui_accept"):
		_gestionar_avance()

func _gui_input(event: InputEvent) -> void:
	if DialogueActors.cinematica_activa:
		return
	
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		_gestionar_avance()

func _gestionar_avance() -> void:
	
	if DialogueActors.cinematica_activa:
		return
	
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
			_mostrar_linea()
		else:
			hide()
			emit_signal("dialogo_finalizado")


func _al_respuesta_seleccionada(response: Variant) -> void:
	# Dialogue Manager provee un objeto de respuesta dinámico (Variant) con `next_id`.
	# Se mantiene Variant para compatibilidad con la API del plugin.
	responses_menu.hide()

	current_line = await DialogueManager.get_next_dialogue_line(
		dialogue_resource,
		response.next_id
	)

	if current_line:
		_mostrar_linea()
	else:
		hide()
		emit_signal("dialogo_finalizado")
