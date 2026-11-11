extends Node
## Presentación táctil: conserva fuentes, colores y recursos del juego.
## Se aplica después de _ready, incluyendo etiquetas creadas dinámicamente.

const BODY_SIZE := 48
const TOUCH_HEIGHT := 104.0
const STYLED := &"mobile_text_styled"
const PREPARED := &"mobile_layout_prepared"
var _dirty := true
var _last_scene_id := 0
var _story_frame_active := false
var _previous_canvas := Transform2D.IDENTITY

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is Control:
		_dirty = true

func _process(_delta: float) -> void:
	if not MobileControlsSettings.is_mobile_device():
		return
	var scene := get_tree().current_scene
	if scene == null:
		return
	var scene_id := scene.get_instance_id()
	if scene_id != _last_scene_id:
		_restore_story_frame()
		_last_scene_id = scene_id
		_dirty = true
	if not _dirty:
		return
	_dirty = false
	_prepare_scene(scene)
	_style_tree(scene)
	_refresh_pause_position(scene)

func _refresh_pause_position(scene: Node) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(scene):
		return
	var pause := scene.get_node_or_null("PauseOverlay")
	if pause != null:
		pause._adaptar_posicion_a_interfaz()

func _style_tree(node: Node) -> void:
	if node is Control and not node.has_meta(STYLED):
		node.set_meta(STYLED, true)
		_style_control(node)
	for child: Node in node.get_children():
		if not child.is_queued_for_deletion():
			_style_tree(child)

func _style_control(control: Control) -> void:
	# Los paneles interiores deben dejar llegar el gesto al ScrollContainer.
	var ancestor: Node = control.get_parent()
	while ancestor != null:
		if ancestor is ScrollContainer:
			if not (control is Range or control is LineEdit or control is TextEdit or control is ScrollContainer):
				if control.mouse_filter == Control.MOUSE_FILTER_STOP:
					control.mouse_filter = Control.MOUSE_FILTER_PASS
			break
		ancestor = ancestor.get_parent()
	if control is Button and control.text.is_empty():
		return
	# Estas dos interfaces ajustan sus propias cajas y fuentes.
	if control is RichTextLabel and (control.name == "DialogueLabel" or control.name == "CharacterLabel" or control.name == "PreguntaRichTextLabel"):
		return
	if control is Label or control is Button or control is LineEdit or control is RichTextLabel:
		var key := "normal_font_size" if control is RichTextLabel else "font_size"
		var zoom := maxf(0.1, control.get_global_transform_with_canvas().x.length())
		var minimum := ceili(BODY_SIZE / zoom)
		control.add_theme_font_size_override(key, maxi(control.get_theme_font_size(key), minimum))
		if control is Label and control.get_parent() is Container:
			control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			control.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		if control is Button and control.get_parent() is Container:
			control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			control.custom_minimum_size.y = maxf(control.custom_minimum_size.y, TOUCH_HEIGHT)
			var font := control.get_theme_font("font")
			var text_width := 0.0
			for line: String in control.text.split("\n"):
				text_width = maxf(text_width, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, control.get_theme_font_size("font_size")).x)
			var padding := control.get_theme_stylebox("normal").get_minimum_size().x + 32.0
			var parent_width := control.get_parent_control().size.x
			var available_width := parent_width if parent_width > 100.0 else control.get_viewport_rect().size.x - 96.0
			control.custom_minimum_size.x = maxf(control.custom_minimum_size.x, minf(text_width + padding, available_width))
		elif control is Button and control.name == "SkipButton":
			control.offset_left = -440
			control.offset_right = -32
			control.offset_top = 20
			control.offset_bottom = 124
		if control is LineEdit:
			control.custom_minimum_size.y = maxf(control.custom_minimum_size.y, TOUCH_HEIGHT)
	if control is HSlider:
		control.custom_minimum_size.y = maxf(control.custom_minimum_size.y, 72.0)
		control.tooltip_text = ""
	if control is OptionButton:
		control.get_popup().add_theme_font_size_override("font_size", BODY_SIZE)
		control.get_popup().add_theme_constant_override("v_separation", 24)

func _prepare_scene(scene: Node) -> void:
	if not scene.has_meta(PREPARED):
		scene.set_meta(PREPARED, true)
		var path := scene.scene_file_path
		if scene.has_node("DialogueUI/Balloon") and (scene.has_node("personajes") or scene.has_node("Personajes")):
			_frame_story(scene)
		if path.ends_with("Tutorial.tscn"):
			_prepare_tutorial(scene)
		elif path.ends_with("/configuracion.tscn"):
			_prepare_settings(scene)
		elif path.ends_with("/resultado_final.tscn"):
			_scroll_content(scene.get_node("MarginContainer/VBoxPrincipal"))
			_vertical_actions(scene.get_node("MarginContainer/MobileScroll/VBoxPrincipal/Botones"))
		elif path.ends_with("/Personalizacion.tscn"):
			scene.get_node("CanvasLayer/PanelLateral").offset_left = 1168
			_scroll_content(scene.get_node("CanvasLayer/PanelLateral/Contenido"))
			for explanation: Node in scene.find_children("Explicacion", "Label", true, false):
				explanation.show()
		elif path.ends_with("/menu_guardados.tscn"):
			_prepare_saved_games(scene)
		elif path.ends_with("/intro_seleccion_genero.tscn"):
			for button: Node in scene.find_children("Contenedor*", "Button", true, false):
				button.custom_minimum_size.y = 420.0
		elif path.ends_with("/creditos.tscn"):
			var margin: Control = scene.get_node("MargenPrincipal")
			margin.offset_left = 48.0
			margin.offset_right = -48.0
		elif path.ends_with("/mapa_topos.tscn"):
			_prepare_clown_result(scene)
		elif path.ends_with("/EscenaCuestionario.tscn"):
			_prepare_quiz(scene)
		elif path.ends_with("/mision_3_nuevo/minijuego3.tscn"):
			# Los letreros del escenario son decorativos; tocar sobre ellos también
			# debe permitir saltar, igual que tocar el resto del recorrido.
			for control: Node in scene.get_node("TilemapLayers").find_children("*", "Control", true, false):
				if control is Label or control is RichTextLabel:
					control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		elif path.ends_with("/mapa_rejugabilidad.tscn"):
			var exit: Control = scene.get_node("%BotonSalirMenu")
			exit.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
			exit.offset_left = -660
			exit.offset_right = -32
			exit.offset_top = -140
			exit.offset_bottom = -32
		elif path.ends_with("/mision_2_memorias.tscn"):
			_prepare_memory_selector(scene.get_node("SelectorEmocion"))
			var feedback: Control = scene.get_node("Retroalimentacion")
			feedback.offset_left = -860
			feedback.offset_right = 860
			feedback.offset_top = 780
			feedback.offset_bottom = 1040
	# La pausa puede añadirse después de preparar la escena.
	var pause := scene.get_node_or_null("PauseOverlay")
	if pause != null and not pause.has_meta(PREPARED):
		pause.set_meta(PREPARED, true)
		pause.get_node("PanelPausa/CenterContainer/VBox").custom_minimum_size = Vector2(1080, 740)
	# El panel de victoria se conserva dentro de su CanvasLayer original.
	var victory := scene.get_node_or_null("NivelCompletadoUI")
	if victory != null and not victory.has_meta(PREPARED):
		_prepare_collection_result(victory)

func _scroll_content(content: Control) -> ScrollContainer:
	var parent := content.get_parent()
	var scroll := ScrollContainer.new()
	scroll.name = "MobileScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(scroll)
	content.reparent(scroll, false)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	return scroll

func _vertical_actions(row: Control) -> void:
	if not row is HBoxContainer:
		return
	var parent := row.get_parent()
	var index := row.get_index()
	var column := VBoxContainer.new()
	var original_name := row.name
	row.name = "OldActions"
	column.name = original_name
	column.add_theme_constant_override("separation", 16)
	parent.add_child(column)
	parent.move_child(column, index)
	for child: Node in row.get_children():
		child.reparent(column, false)
		if child is Control:
			child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.queue_free()

func _prepare_settings(scene: Node) -> void:
	scene.get_node("Fondo_Config").scale = Vector2(37.5, 23.0)
	scene.get_node("Fondo_Config").position = Vector2(960, 690)
	var index := 0
	for row_name: String in ["Master", "Musica", "SFX", "Controles"]:
		var row: Control = scene.get_node(row_name)
		row.position = Vector2(480, 450 + index * 120)
		row.size = Vector2(960, 104)
		for child: Node in row.get_children():
			if child is Label:
				child.size_flags_stretch_ratio = 1.25
		index += 1
	var back: Control = scene.get_node("BtnVolver")
	back.position = Vector2(480, 950)
	back.size = Vector2(960, 104)
	back.add_theme_font_size_override("font_size", BODY_SIZE)

func _prepare_saved_games(scene: Node) -> void:
	var panel: Control = scene.get_node("CenterContainer/PanelContainer")
	panel.custom_minimum_size = Vector2(1700, 960)
	var scroll: ScrollContainer = scene.scroll_partidas
	scroll.custom_minimum_size.y = 480
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	# El marco conserva su altura; el contenido de las filas puede crecer.
	var empty: Label = scene.etiqueta_vacio
	empty.custom_minimum_size.y = 360

func _prepare_clown_result(scene: Node) -> void:
	var panel: Control = scene.get_node("%PantallaResultado")
	panel.offset_left = -640
	panel.offset_right = 640
	panel.offset_top = -300
	panel.offset_bottom = 300
	var detail: Label = scene.get_node("%DetalleResultado")
	detail.custom_minimum_size.y = 200
	var actions: Control = scene.get_node("CanvasLayer/PantallaResultado/MarginContainer/VBoxResultado/HBoxAcciones")
	for button: Node in actions.get_children():
		button.custom_minimum_size = Vector2(520, TOUCH_HEIGHT)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _prepare_collection_result(layer: CanvasLayer) -> void:
	layer.set_meta(PREPARED, true)
	layer.offset = Vector2(510, 0)
	var backdrop: Control = layer.get_node("Control/FondoOscuro")
	backdrop.offset_left = -510
	backdrop.offset_right = 1410
	layer.get_node("Control/ResplandorPanel").offset_right = 916
	var panel: Control = layer.get_node("Control/Panel")
	panel.size = Vector2(900, 1060)
	_scroll_content(panel.get_node("VBoxContainer"))
	var preview: Control = layer.get_node("Control/Panel/MobileScroll/VBoxContainer/ControlJugador")
	var message: Label = preview.get_node("MensajeVictoria")
	message.offset_left = -390
	message.offset_right = 390
	message.offset_top = 8
	message.offset_bottom = 150
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for decoration: String in ["OrnamentoIzquierdo", "OrnamentoDerecho", "EstrellaCentral"]:
		preview.get_node(decoration).hide()
	var action: Control = layer.get_node("Control/Panel/MobileScroll/VBoxContainer/ControlBoton")
	action.custom_minimum_size.y = 140
	var button: Control = action.get_node("BotonContinuar")
	button.scale = Vector2.ONE
	button.position = Vector2(310, 10)
	button.size = Vector2(240, 120)

func _prepare_quiz(scene: Node) -> void:
	for index in range(scene.botones_opciones.size()):
		var button: Button = scene.botones_opciones[index]
		button.set_meta(STYLED, true)
		button.add_theme_font_size_override("font_size", BODY_SIZE)
		button.autowrap_mode = TextServer.AUTOWRAP_OFF
		button.custom_minimum_size = Vector2(460 if index < 4 else 520, 104)
		for state: String in ["normal", "hover", "pressed", "disabled"]:
			var style: StyleBox = button.get_theme_stylebox(state).duplicate()
			style.content_margin_top = 8
			style.content_margin_bottom = 8
			button.add_theme_stylebox_override(state, style)
	var row: HBoxContainer = scene.botones_opciones[0].get_parent().get_parent()
	row.add_theme_constant_override("separation", 16)

func _restore_story_frame() -> void:
	if _story_frame_active:
		get_viewport().canvas_transform = _previous_canvas
		_story_frame_active = false
		# Una cámara nueva puede haberse actualizado antes de restaurar el encuadre.
		var camera := get_viewport().get_camera_2d()
		if camera != null:
			camera.force_update_scroll()

func _frame_story(scene: Node) -> void:
	var actors := scene.get_node_or_null("personajes")
	if actors == null:
		actors = scene.get_node("Personajes")
	var bounds := _actor_bounds(actors)
	if not bounds.has_area():
		return
	_previous_canvas = get_viewport().canvas_transform
	_story_frame_active = true
	# Sólo cambia el encuadre del lienzo: las posiciones y los desplazamientos
	# globales usados por la coreografía mantienen sus unidades originales.
	var zoom := minf(1.0, minf(1840.0 / (bounds.size.x + 100), 570.0 / (bounds.size.y + 80)))
	var offset := Vector2((1920 - 1920 * zoom) / 2, 315 - bounds.get_center().y * zoom)
	if not scene.has_node("MobileStoryMatte"):
		var matte := CanvasLayer.new()
		matte.name = "MobileStoryMatte"
		matte.layer = -100
		scene.add_child(matte)
		var background := ColorRect.new()
		background.color = Color("#090611")
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		background.size = Vector2(1920, 1080)
		matte.add_child(background)
	get_viewport().canvas_transform = Transform2D(Vector2(zoom, 0), Vector2(0, zoom), offset)
	scene.set_meta("mobile_actor_bounds", bounds)
	scene.set_meta("mobile_story_stage", Rect2(0, 0, 1920, 630))

func _actor_bounds(node: Node) -> Rect2:
	var bounds := Rect2()
	if String(node.name).to_lower().contains("fondo"):
		return bounds
	# Las referencias de autoría ocultas contienen hojas completas de sprites;
	# no forman parte del reparto que debe entrar en el encuadre.
	if node is CanvasItem and not node.visible:
		return bounds
	var texture: Texture2D
	var rect := Rect2()
	if node is Sprite2D:
		texture = node.texture
		rect = node.get_rect()
	elif node is AnimatedSprite2D and node.sprite_frames != null:
		texture = node.sprite_frames.get_frame_texture(node.animation, node.frame)
		if texture != null:
			rect = Rect2(-texture.get_size() / 2 + node.offset, texture.get_size())
	if texture != null:
		var image := texture.get_image()
		if image != null and not image.is_empty():
			var used := Rect2(image.get_used_rect())
			if used.has_area():
				rect = Rect2(rect.position + used.position * rect.size / texture.get_size(), used.size * rect.size / texture.get_size())
		var world_rect: Rect2 = node.get_global_transform() * rect
		# Algunos fondos están dentro del contenedor de personajes.
		if world_rect.size.x < 1800 and world_rect.size.y < 1050:
			bounds = world_rect
	for child: Node in node.get_children():
		var child_bounds := _actor_bounds(child)
		if child_bounds.has_area():
			bounds = bounds.merge(child_bounds) if bounds.has_area() else child_bounds
	return bounds

func _place(control: Control, rect: Rect2) -> void:
	control.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	control.position = rect.position
	control.size = rect.size

func _prepare_tutorial(scene: Node) -> void:
	var panel: Control = scene.get_node_or_null("TutorialUI/Overlay/BottomPanel")
	var content: VBoxContainer
	var navigation: Control
	if panel != null:
		content = panel.get_node("MarginContainer/VBoxContainer")
		navigation = content.get_node("NavigationRow")
		var bar: Control = scene.get_node("TutorialUI/Overlay/TopBar")
		_place(bar, Rect2(32, 20, 1856, 104))
	else:
		panel = scene.get_node("Bottom")
		content = panel.get_node("VBox")
		navigation = content.get_node("Navigation")
		_place(scene.get_node("Title"), Rect2(32, 20, 1230, 104))
	_place(panel, Rect2(1090, 170, 790, 870))
	var scroll := ScrollContainer.new()
	scroll.name = "MobileInstructionScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	content.move_child(scroll, 0)
	var body := VBoxContainer.new()
	body.name = "Instructions"
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
	for child: Node in content.get_children():
		if child != scroll and child != navigation:
			child.reparent(body, false)
	if scene.has_node("Subtitle"):
		var subtitle: Control = scene.get_node("Subtitle")
		subtitle.reparent(body, false)
		body.move_child(subtitle, 0)
		# Su texto se conserva en el panel, con el ancho disponible para envolver.
		subtitle.custom_minimum_size = Vector2.ZERO
	_vertical_actions(navigation)
	var area := Rect2(40, 180, 1010, 840)
	var demo: CanvasItem
	var source: Rect2
	if scene.has_node("DemoWorld"):
		demo = scene.get_node("DemoWorld")
		source = Rect2(270, 120, 1380, 680)
	elif scene.has_node("TutorialDemo"):
		_prepare_memory_demo(scene.get_node("TutorialDemo"))
		return
	else:
		demo = scene.get_node("Arena")
		source = Rect2(Vector2.ZERO, demo.size)
		# Los indicadores se leen fuera del recorrido del personaje y del martillo.
		var captions := VBoxContainer.new()
		captions.name = "MobileDemoCaptions"
		scene.add_child(captions)
		_place(captions, Rect2(40, 190, 1010, 220))
		var title_name := "RouteLabel" if demo.has_node("RouteLabel") else "DemoLabel"
		var title: Label = demo.get_node(title_name)
		title.reparent(captions, false)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 32)
		captions.add_child(row)
		for caption_name: String in ["JumpHint", "Score", "SpeedLabel", "AimHint"]:
			var caption: Label = demo.get_node_or_null(caption_name)
			if caption != null:
				caption.reparent(row, false)
				caption.custom_minimum_size = Vector2.ZERO
				caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		area = Rect2(40, 440, 1010, 560)
	var zoom := minf(area.size.x / source.size.x, area.size.y / source.size.y)
	if demo is Control:
		demo.pivot_offset = Vector2.ZERO
		demo.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		demo.size = source.size
	demo.scale = Vector2.ONE * zoom
	demo.position = area.get_center() - source.get_center() * zoom

func _prepare_memory_demo(demo: Control) -> void:
	# Fotografías arriba y emociones debajo, sin reducir las etiquetas a miniaturas.
	_place(demo, Rect2(40, 170, 1010, 870))
	_place(demo.get_node("TopInfo"), Rect2(0, 0, 1010, 150))
	var photos: GridContainer = demo.photos_grid
	for photo: Control in photos.get_children():
		photo.custom_minimum_size = Vector2(230, 96)
		var checkmark: Label = photo.get_node("Check")
		checkmark.set_meta(STYLED, true)
		# Conserva al menos 14 px incluso durante el pulso de escala 0.96.
		checkmark.add_theme_font_size_override("font_size", 44)
	_place(photos, Rect2(0, 164, 1010, 212))
	demo._photos_grid_default_position = photos.position
	var emotions: PanelContainer = demo.emotion_panel
	var margin: MarginContainer = emotions.get_node("MarginContainer")
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	margin.get_node("VBoxContainer").add_theme_constant_override("separation", 8)
	demo.emotions_grid.columns = 4
	for button: Control in demo.emotions_grid.get_children():
		button.custom_minimum_size = Vector2(210, 104)
		button.set_meta(STYLED, true)
		button.add_theme_font_size_override("font_size", BODY_SIZE)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(emotions, Rect2(0, 390, 1010, 480))

func _prepare_memory_selector(selector: Control) -> void:
	var choices: GridContainer = selector.emojis_container
	choices.scale = Vector2.ONE
	choices.columns = 2
	choices.add_theme_constant_override("h_separation", 24)
	choices.add_theme_constant_override("v_separation", 22)
	_place(choices, Rect2(60, 260, 520, 776))
	for button: Node in choices.get_children():
		if not button is TextureButton:
			continue
		button.ignore_texture_size = true
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		button.custom_minimum_size = Vector2(104, 90)
		button.tooltip_text = ""
		var caption := Label.new()
		caption.name = "EmotionName_" + button.emocion_id
		caption.text = button.emocion_id.capitalize()
		caption.custom_minimum_size.x = 340
		caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		caption.mouse_filter = Control.MOUSE_FILTER_STOP
		caption.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		caption.gui_input.connect(_select_emotion_caption.bind(button))
		choices.add_child(caption)
		choices.move_child(caption, button.get_index() + 1)
	var title := Label.new()
	title.text = "Elige una emoción"
	selector.add_child(title)
	_place(title, Rect2(60, 140, 600, 100))
	_place(selector.visor, Rect2(650, 170, 720, 720))
	selector.emoji_grande.position = Vector2(660, 70)
	for action: String in ["Confirmar", "Cancelar"]:
		var left := 1440 if action == "Confirmar" else 1700
		var button: Button = selector.get_node("Boton" + action)
		_place(button, Rect2(left, 550, 140, 140))
		var caption := Label.new()
		caption.text = action
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		selector.add_child(caption)
		_place(caption, Rect2(left - 50, 710, 240, 110))

func _select_emotion_caption(event: InputEvent, button: TextureButton) -> void:
	# El nombre amplía el área de elección; los toques generan el mismo evento
	# de ratón que emplean los botones originales, sin duplicar la selección.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not button.disabled:
		button.pressed.emit()
