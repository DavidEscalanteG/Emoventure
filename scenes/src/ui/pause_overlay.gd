extends CanvasLayer

const MENU_PRINCIPAL_PATH := "res://scenes/menu_principal/menu_principal.tscn"

@onready var btn_pausa: Button = %BtnPausa
@onready var panel_pausa: Panel = %PanelPausa
@onready var slider_musica: HSlider = %SliderMusica
@onready var slider_sfx: HSlider = %SliderSFX
@onready var option_controles: OptionButton = %OptionControles


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	btn_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	panel_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	panel_pausa.visible = false
	_configurar_audio()
	_configurar_controles_moviles()


func _configurar_audio() -> void:
	slider_musica.value = AudioManager.get_volumen(AudioManager.BUS_MUSICA)
	slider_sfx.value = AudioManager.get_volumen(AudioManager.BUS_SFX)


func _configurar_controles_moviles() -> void:
	option_controles.clear()
	option_controles.add_item("Sin controles táctiles")
	option_controles.add_item("Cruceta")
	option_controles.add_item("Joystick")
	match MobileControlsSettings.control_mode:
		MobileControlsSettings.MODE_OFF:
			option_controles.select(0)
		MobileControlsSettings.MODE_JOYSTICK:
			option_controles.select(2)
		_:
			option_controles.select(1)


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
	match index:
		0:
			MobileControlsSettings.set_control_mode(MobileControlsSettings.MODE_OFF)
		1:
			MobileControlsSettings.set_control_mode(MobileControlsSettings.MODE_CRUCETA)
		2:
			MobileControlsSettings.set_control_mode(MobileControlsSettings.MODE_JOYSTICK)
	AudioManager.play_ui_click()


func _set_pausa_activa(estado: bool) -> void:
	get_tree().paused = estado
	panel_pausa.visible = estado
	if estado:
		AudioManager.play_ui_click()
