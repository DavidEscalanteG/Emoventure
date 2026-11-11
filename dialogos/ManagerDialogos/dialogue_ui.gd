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
var _mobile_scroll: ScrollContainer
var _mobile_hint: Label
var _mobile_continue: Button
var _mobile_responses: ScrollContainer


signal dialogo_finalizado

func _ready() -> void:
	label.bbcode_enabled = true
	type_timer.timeout.connect(_al_tictac_tipeo)

	responses_menu.response_selected.connect(_al_respuesta_seleccionada)
	responses_menu.hide()
	if MobileControlsSettings.is_mobile_device():
		_crear_interfaz_movil()


func _crear_interfaz_movil() -> void:
	label.add_theme_font_size_override("normal_font_size", 54)
	label.add_theme_constant_override("outline_size", 2)
	character_label.add_theme_font_size_override("normal_font_size", 48)
	character_label.add_theme_constant_override("outline_size", 2)
	var content := label.get_parent()
	var header := HBoxContainer.new()
	header.name = "MobileDialogueActions"
	header.custom_minimum_size.y = 104
	content.add_child(header)
	content.move_child(header, 0)
	character_label.reparent(header, false)
	character_label.custom_minimum_size.x = 560
	character_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_mobile_hint = Label.new()
	_mobile_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_mobile_hint)
	_mobile_continue = Button.new()
	_mobile_continue.text = "Continuar"
	_mobile_continue.custom_minimum_size = Vector2(380, 104)
	_mobile_continue.pressed.connect(_gestionar_avance)
	header.add_child(_mobile_continue)
	var body := HBoxContainer.new()
	body.name = "MobileDialogueBody"
	body.custom_minimum_size.y = 250
	body.add_theme_constant_override("separation", 32)
	content.add_child(body)
	_mobile_scroll = ScrollContainer.new()
	_mobile_scroll.name = "MobileDialogueScroll"
	_mobile_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_mobile_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(_mobile_scroll)
	label.reparent(_mobile_scroll, false)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	label.fit_content = true
	label.scroll_active = false
	_mobile_responses = ScrollContainer.new()
	_mobile_responses.name = "MobileResponseScroll"
	_mobile_responses.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_mobile_responses.custom_minimum_size.x = 780
	_mobile_responses.follow_focus = true
	body.add_child(_mobile_responses)
	responses_menu.reparent(_mobile_responses, false)
	responses_menu.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	responses_menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	responses_menu.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var background: ColorRect = $MarginContainer/PanelContainer/ColorRect
	background.color = Color(0.025, 0.018, 0.05, 0.96)
	var template: Button = responses_menu.response_template
	template.add_theme_font_size_override("font_size", 48)
	template.custom_minimum_size.y = 104
	template.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	responses_menu.add_theme_constant_override("separation", 16)
	_ajustar_caja_movil()


func _ajustar_caja_movil() -> void:
	if _mobile_scroll == null:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_inside_tree():
		return
	_mobile_responses.visible = responses_menu.visible
	_mobile_continue.visible = not responses_menu.visible
	_mobile_hint.text = "Elige una respuesta" if responses_menu.visible else ("Desliza para leer" if label.get_content_height() > 250 else "")
	# Altura constante: ni las líneas largas ni las opciones invaden el escenario.
	$MarginContainer.offset_top = -430

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
		
		var nombre_mascota: String = String(DatosJugador.get("nombre_mascota")).strip_edges()
		
		match current_line.character:
			"Gitana", "???":
				type_sound.pitch_scale = 0.85
				character_label.modulate = Color("#ff8a9a") # Carmesí muy claro / Rosa coral
			"Mujer Lagarto":
				type_sound.pitch_scale = 1.0
				character_label.modulate = Color("#fff59d") # Amarillo claro brillante
			nombre_mascota, "{{DatosJugador.nombre_mascota}}", "Mascota":
				# La mascota suena un poco más aguda
				type_sound.pitch_scale = 1.2
				character_label.modulate = Color("#ffb8e0") # Rosa pastel claro
			"Payaso":
				type_sound.pitch_scale = 1.1
				character_label.modulate = Color("#80d8ff") # Azul cielo muy claro
			"Frankenstein":
				# Voz lenta y muy grave
				type_sound.pitch_scale = 0.6
				character_label.modulate = Color("#98fb98") # Verde pálido / Menta claro
			"Narrador":
				type_sound.pitch_scale = 1.0
				character_label.modulate = Color("#e1a5ff") # Morado / Lavanda muy claro
			"Domador":
				type_sound.pitch_scale = 0.95
				character_label.modulate = Color("#ffcc80") # Naranja durazno claro
			"Parca":
				# Voz casi de ultratumba
				type_sound.pitch_scale = 0.5
				character_label.modulate = Color("#e0e0e0") # Gris muy claro / Plata
			_:
				type_sound.pitch_scale = 1.0
				character_label.modulate = Color.WHITE
	else:
		character_label.hide()

	if _mobile_scroll != null:
		_mobile_scroll.scroll_vertical = 0

	label.text = current_line.text
	label.visible_characters = 0
	visible_chars = 0
	line_finished = false

	responses_menu.hide()
	type_timer.start()
	_ajustar_caja_movil()


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
	_ajustar_caja_movil()
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
		if current_line.responses.size() > 0:
			_mostrar_respuestas()
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
