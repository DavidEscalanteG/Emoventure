extends Control

@onready var slider_master: HSlider = %SliderMaster
@onready var slider_musica: HSlider = %SliderMusica
@onready var slider_sfx: HSlider = %SliderSFX
@onready var slider_voz: HSlider = %SliderVoz
@onready var option_controles: OptionButton = %OptionControles

const MUSIC_PREVIEW := "res://audios/musica/menu_principal.mp3"
const SFX_PREVIEW := "res://audios/sfx/ui_click.mp3"


func _ready() -> void:
	InteractiveButtonFX.aplicar_a_botones_en(self)
	slider_master.value = AudioManager.get_volumen(AudioManager.BUS_MASTER)
	slider_musica.value = AudioManager.get_volumen(AudioManager.BUS_MUSICA)
	slider_sfx.value = AudioManager.get_volumen(AudioManager.BUS_SFX)
	slider_voz.value = AudioManager.get_volumen(AudioManager.BUS_VOZ)
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
	match index:
		0:
			MobileControlsSettings.set_control_mode(MobileControlsSettings.MODE_OFF)
		1:
			MobileControlsSettings.set_control_mode(MobileControlsSettings.MODE_CRUCETA)
		2:
			MobileControlsSettings.set_control_mode(MobileControlsSettings.MODE_JOYSTICK)
	AudioManager.play_ui_click()
