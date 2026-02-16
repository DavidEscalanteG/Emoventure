extends Control

@onready var slider_master: HSlider = %SliderMaster
@onready var slider_musica: HSlider = %SliderMusica
@onready var slider_sfx: HSlider = %SliderSFX
@onready var slider_voz: HSlider = %SliderVoz

const MUSIC_PREVIEW: String = "res://audios/musica/menu_principal.mp3"
const SFX_PREVIEW: String = "res://audios/sfx/ui_click.mp3"

const BUS_MASTER: String = "Master"
const BUS_MUSICA: String = "Musica"
const BUS_SFX: String = "SFX"
const BUS_VOZ: String = "Voz"


func _get_audio_manager() -> Object:
	if Engine.has_singleton("AudioManager"):
		return Engine.get_singleton("AudioManager")
	return null


func _get_music_manager() -> Object:
	if Engine.has_singleton("MusicManager"):
		return Engine.get_singleton("MusicManager")
	return null


func _ready() -> void:
	var audio_manager: Object = _get_audio_manager()
	if audio_manager == null:
		push_error("AudioManager no está disponible.")
		return

	slider_master.value = float(audio_manager.call("get_volumen", BUS_MASTER))
	slider_musica.value = float(audio_manager.call("get_volumen", BUS_MUSICA))
	slider_sfx.value = float(audio_manager.call("get_volumen", BUS_SFX))
	slider_voz.value = float(audio_manager.call("get_volumen", BUS_VOZ))


func _on_slider_master_value_changed(value: float) -> void:
	var audio_manager: Object = _get_audio_manager()
	if audio_manager == null:
		return
	audio_manager.call("set_volumen", BUS_MASTER, value)


func _on_slider_musica_value_changed(value: float) -> void:
	var audio_manager: Object = _get_audio_manager()
	if audio_manager == null:
		return
	audio_manager.call("set_volumen", BUS_MUSICA, value)


func _on_slider_sfx_value_changed(value: float) -> void:
	var audio_manager: Object = _get_audio_manager()
	if audio_manager == null:
		return
	audio_manager.call("set_volumen", BUS_SFX, value)


func _on_slider_voz_value_changed(value: float) -> void:
	var audio_manager: Object = _get_audio_manager()
	if audio_manager == null:
		return
	audio_manager.call("set_volumen", BUS_VOZ, value)


func _on_btn_probar_musica_pressed() -> void:
	var music_manager: Object = _get_music_manager()
	if music_manager == null:
		return
	music_manager.call("reproducir_desde_ruta", MUSIC_PREVIEW)


func _on_btn_probar_sfx_pressed() -> void:
	var audio_manager: Object = _get_audio_manager()
	if audio_manager == null:
		return
	audio_manager.call("play_sfx", SFX_PREVIEW)


func _on_btn_volver_pressed() -> void:
	var audio_manager: Object = _get_audio_manager()
	if audio_manager != null:
		audio_manager.call("play_ui_click")
	get_tree().change_scene_to_file("res://scenes/menu_principal/menu_principal.tscn")
