extends Control

@onready var slider_master: HSlider = %SliderMaster
@onready var slider_musica: HSlider = %SliderMusica
@onready var slider_sfx: HSlider = %SliderSFX
@onready var slider_voz: HSlider = %SliderVoz
@onready var option_controles: OptionButton = %OptionControles
@onready var label_controles: Label = %LabelControles
@onready var btn_teclado: Button = %BtnTeclado
@onready var panel_teclado: PopupPanel = %PanelTeclado
@onready var estado_teclado: Label = %EstadoTeclado
@onready var botones_teclas: Dictionary[String, Button] = {
	"move_up": %TeclaArriba,
	"move_down": %TeclaAbajo,
	"move_left": %TeclaIzquierda,
	"move_right": %TeclaDerecha,
}

const MUSIC_PREVIEW := "res://audios/musica/menu_principal.ogg"
const SFX_PREVIEW := "res://audios/sfx/ui_click.mp3"
var _accion_esperando_tecla: String = ""


func _ready() -> void:
	InteractiveButtonFX.aplicar_a_botones_en(self)

	for slider: HSlider in [slider_master, slider_musica, slider_sfx, slider_voz]:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01

	if not slider_master.value_changed.is_connected(_on_slider_master_value_changed):
		slider_master.value_changed.connect(_on_slider_master_value_changed)
	if not slider_musica.value_changed.is_connected(_on_slider_musica_value_changed):
		slider_musica.value_changed.connect(_on_slider_musica_value_changed)
	if not slider_sfx.value_changed.is_connected(_on_slider_sfx_value_changed):
		slider_sfx.value_changed.connect(_on_slider_sfx_value_changed)
	if not slider_voz.value_changed.is_connected(_on_slider_voz_value_changed):
		slider_voz.value_changed.connect(_on_slider_voz_value_changed)

	slider_master.set_value_no_signal(AudioManager.get_volumen(AudioManager.BUS_MASTER))
	slider_musica.set_value_no_signal(AudioManager.get_volumen(AudioManager.BUS_MUSICA))
	slider_sfx.set_value_no_signal(AudioManager.get_volumen(AudioManager.BUS_SFX))
	slider_voz.set_value_no_signal(AudioManager.get_volumen(AudioManager.BUS_VOZ))

	_configurar_selector_controles()


func _configurar_selector_controles() -> void:
	option_controles.clear()
	if not MobileControlsSettings.is_mobile_device():
		label_controles.text = "Controles de teclado"
		option_controles.visible = false
		btn_teclado.visible = true
		_actualizar_botones_teclado()
		return
	label_controles.text = "Controles móvil"
	btn_teclado.visible = false
	option_controles.visible = true
	option_controles.disabled = false
	option_controles.add_item("Cruceta")
	option_controles.set_item_metadata(0, MobileControlsSettings.MODE_CRUCETA)
	option_controles.add_item("Joystick")
	option_controles.set_item_metadata(1, MobileControlsSettings.MODE_JOYSTICK)
	option_controles.select(1 if MobileControlsSettings.control_mode == MobileControlsSettings.MODE_JOYSTICK else 0)


func _on_slider_master_value_changed(value: float) -> void:
	AudioManager.set_volumen(AudioManager.BUS_MASTER, value)


func _on_slider_musica_value_changed(value: float) -> void:
	AudioManager.set_volumen(AudioManager.BUS_MUSICA, value)


func _on_slider_sfx_value_changed(value: float) -> void:
	AudioManager.set_volumen(AudioManager.BUS_SFX, value)


func _on_slider_voz_value_changed(value: float) -> void:
	AudioManager.set_volumen(AudioManager.BUS_VOZ, value)


func _on_btn_probar_musica_pressed() -> void:
	AudioManager.play_ui_click()
	MusicManager.reproducir_desde_ruta(MUSIC_PREVIEW)


func _on_btn_probar_sfx_pressed() -> void:
	AudioManager.play_ui_click()
	AudioManager.play_sfx(SFX_PREVIEW)


func _on_btn_volver_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/menu_principal/menu_principal.tscn")


func _on_option_controles_item_selected(index: int) -> void:
	var mode: String = String(option_controles.get_item_metadata(index))
	MobileControlsSettings.set_control_mode(mode)
	AudioManager.play_ui_click()


func _on_btn_teclado_pressed() -> void:
	_accion_esperando_tecla = ""
	estado_teclado.text = "WASD y flechas siempre permanecen activos. Puedes agregar una tecla extra."
	_actualizar_botones_teclado()
	panel_teclado.popup_centered(Vector2i(780, 480))
	AudioManager.play_ui_click()


func _esperar_tecla(action: String) -> void:
	_accion_esperando_tecla = action
	estado_teclado.text = "Presiona la tecla adicional (Esc para cancelar)."
	for button: Button in botones_teclas.values():
		button.disabled = true


func _unhandled_key_input(event: InputEvent) -> void:
	if _capturar_tecla_personalizada(event):
		get_viewport().set_input_as_handled()


func _on_panel_teclado_window_input(event: InputEvent) -> void:
	if _capturar_tecla_personalizada(event):
		panel_teclado.set_input_as_handled()


func _capturar_tecla_personalizada(event: InputEvent) -> bool:
	if _accion_esperando_tecla.is_empty() or not (event is InputEventKey):
		return false
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return false
	if key_event.physical_keycode != KEY_ESCAPE:
		MobileControlsSettings.set_custom_key(_accion_esperando_tecla, key_event.physical_keycode)
	_accion_esperando_tecla = ""
	estado_teclado.text = "WASD y flechas siempre permanecen activos. Puedes agregar una tecla extra."
	_actualizar_botones_teclado()
	return true


func _actualizar_botones_teclado() -> void:
	for action: String in botones_teclas:
		botones_teclas[action].text = MobileControlsSettings.get_custom_key_text(action)
		botones_teclas[action].disabled = false


func _on_tecla_arriba_pressed() -> void: _esperar_tecla("move_up")
func _on_tecla_abajo_pressed() -> void: _esperar_tecla("move_down")
func _on_tecla_izquierda_pressed() -> void: _esperar_tecla("move_left")
func _on_tecla_derecha_pressed() -> void: _esperar_tecla("move_right")


func _on_restaurar_teclas_pressed() -> void:
	_accion_esperando_tecla = ""
	MobileControlsSettings.clear_custom_keys()
	_actualizar_botones_teclado()
	estado_teclado.text = "Teclas adicionales eliminadas. WASD y flechas siguen activos."
	AudioManager.play_ui_click()


func _on_cerrar_teclado_pressed() -> void:
	_accion_esperando_tecla = ""
	panel_teclado.hide()
	AudioManager.play_ui_click()
