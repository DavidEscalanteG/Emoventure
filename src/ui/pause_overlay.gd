extends CanvasLayer

const MENU_PRINCIPAL_PATH := "res://scenes/menu_principal/menu_principal.tscn"

@onready var btn_pausa: Button = %BtnPausa
@onready var panel_pausa: Panel = %PanelPausa
@onready var slider_musica: HSlider = %SliderMusica
@onready var slider_sfx: HSlider = %SliderSFX
@onready var option_controles: OptionButton = %OptionControles
@onready var pause_container: MarginContainer = $MarginTopRight
@onready var pause_background: ColorRect = $BlurOverlay
var _escape_estaba_presionado: bool = false

const PAUSE_BUTTON_SIZE := Vector2(80.0, 80.0)
const SCREEN_MARGIN := 40.0
const UI_GAP := 18.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	btn_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	panel_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	panel_pausa.visible = false
	_configurar_audio()
	_configurar_controles_moviles()
	call_deferred("_adaptar_posicion_a_interfaz")
	get_viewport().size_changed.connect(_adaptar_posicion_a_interfaz)


func _process(_delta: float) -> void:
	# Se consulta el estado físico para que Escape funcione aunque un Control o
	# un diálogo haya consumido el evento antes de llegar a _input.
	var escape_presionado := Input.is_physical_key_pressed(KEY_ESCAPE)
	if escape_presionado and not _escape_estaba_presionado:
		_alternar_pausa_por_escape()
	_escape_estaba_presionado = escape_presionado


func _alternar_pausa_por_escape() -> void:
	_set_pausa_activa(not get_tree().paused)


func _adaptar_posicion_a_interfaz() -> void:
	var escena_actual := get_tree().current_scene
	if escena_actual == null or not is_instance_valid(btn_pausa):
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var candidate := Rect2(
		Vector2(viewport_size.x - SCREEN_MARGIN - PAUSE_BUTTON_SIZE.x, 24.0),
		PAUSE_BUTTON_SIZE
	)
	var blockers: Array[Rect2] = []
	for node: Node in escena_actual.find_children("*", "Control", true, false):
		var control := node as Control
		if control == null or is_ancestor_of(control) or not control.is_visible_in_tree():
			continue
		if not (control is BaseButton or control is Label):
			continue
		var rect := control.get_global_rect()
		# Los paneles de texto de ancho completo suelen alinear su contenido al
		# lado opuesto. Sólo los elementos compactos son obstáculos reales.
		if rect.size.x <= 0.0 or rect.size.x > viewport_size.x * 0.5:
			continue
		if rect.position.y > 150.0 or rect.end.y < 0.0:
			continue
		blockers.append(rect)

	# Desplaza hacia la izquierda tantas veces como sea necesario, de modo que
	# también funciona si una futura escena añade varios controles en la esquina.
	var moved := true
	while moved:
		moved = false
		for blocker: Rect2 in blockers:
			if candidate.grow(6.0).intersects(blocker):
				candidate.position.x = blocker.position.x - UI_GAP - candidate.size.x
				moved = true
	if candidate.position.x < SCREEN_MARGIN:
		candidate.position.x = SCREEN_MARGIN
		candidate.position.y = 120.0
	_set_pause_button_rect(candidate, viewport_size)


func _set_pause_button_rect(rect: Rect2, viewport_size: Vector2) -> void:
	pause_container.offset_left = rect.position.x - viewport_size.x
	pause_container.offset_top = rect.position.y
	pause_container.offset_right = rect.end.x - viewport_size.x
	pause_container.offset_bottom = rect.end.y
	pause_background.position = rect.position
	pause_background.size = rect.size


func _configurar_audio() -> void:
	slider_musica.value = AudioManager.get_volumen(AudioManager.BUS_MUSICA)
	slider_sfx.value = AudioManager.get_volumen(AudioManager.BUS_SFX)


func _configurar_controles_moviles() -> void:
	option_controles.clear()
	if not MobileControlsSettings.is_mobile_device():
		option_controles.add_item("Desactivados automáticamente")
		option_controles.set_item_metadata(0, MobileControlsSettings.MODE_OFF)
		option_controles.select(0)
		option_controles.disabled = true
		return
	option_controles.disabled = false
	option_controles.add_item("Cruceta")
	option_controles.set_item_metadata(0, MobileControlsSettings.MODE_CRUCETA)
	option_controles.add_item("Joystick")
	option_controles.set_item_metadata(1, MobileControlsSettings.MODE_JOYSTICK)
	option_controles.select(1 if MobileControlsSettings.control_mode == MobileControlsSettings.MODE_JOYSTICK else 0)


func _on_btn_pausa_pressed() -> void:
	_set_pausa_activa(not get_tree().paused)


func _on_btn_reanudar_pressed() -> void:
	_set_pausa_activa(false)


func _on_btn_menu_principal_pressed() -> void:
	_set_pausa_activa(false)
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file(MENU_PRINCIPAL_PATH)


func _on_slider_musica_value_changed(value: float) -> void:
	AudioManager.set_volumen(AudioManager.BUS_MUSICA, value)


func _on_slider_sfx_value_changed(value: float) -> void:
	AudioManager.set_volumen(AudioManager.BUS_SFX, value)


func _on_option_controles_item_selected(index: int) -> void:
	var mode: String = String(option_controles.get_item_metadata(index))
	MobileControlsSettings.set_control_mode(mode)
	AudioManager.play_ui_click()


func _set_pausa_activa(estado: bool) -> void:
	get_tree().paused = estado
	panel_pausa.visible = estado
	
	# --- CORRECCIÓN CLAVE ---
	# Consumimos la entrada para que el clic o la tecla ESC 
	# no sigan propagándose hasta el personaje y provoquen el salto.
	get_viewport().set_input_as_handled()
	
	if estado:
		AudioManager.play_ui_click()
