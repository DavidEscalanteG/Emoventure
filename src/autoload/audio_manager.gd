extends Node

const BUS_MASTER := "Master"
const BUS_MUSICA := "Musica"
const BUS_SFX := "SFX"
const BUS_VOZ := "Voz"

const SETTINGS_PATH := "user://audio_settings.cfg"

const DEFAULT_UI_CLICK_SFX := "res://assets/audio/sfx/ui_click.wav"

var volumenes := {
	BUS_MASTER: 1.0,
	BUS_MUSICA: 0.8,
	BUS_SFX: 1.0,
	BUS_VOZ: 1.0,
}


func _ready() -> void:
	_asegurar_buses_audio()
	_cargar_configuracion_audio()
	_aplicar_volumenes()


func set_volumen(bus_name: String, valor_lineal: float) -> void:
	if not volumenes.has(bus_name):
		push_warning("[AudioManager] Bus desconocido: %s" % bus_name)
		return

	volumenes[bus_name] = clampf(valor_lineal, 0.0, 1.0)
	_aplicar_volumen_bus(bus_name)
	_guardar_configuracion_audio()


func get_volumen(bus_name: String) -> float:
	if not volumenes.has(bus_name):
		return 1.0
	return volumenes[bus_name]


func play_sfx(stream_path: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if stream_path.is_empty():
		return
	if not ResourceLoader.exists(stream_path):
		push_warning("[AudioManager] Efecto no encontrado: %s" % stream_path)
		return

	var stream := load(stream_path) as AudioStream
	if stream == null:
		push_warning("[AudioManager] No se pudo cargar el efecto: %s" % stream_path)
		return

	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.bus = BUS_SFX
	sfx_player.volume_db = volume_db
	sfx_player.pitch_scale = pitch_scale
	sfx_player.finished.connect(sfx_player.queue_free)
	add_child(sfx_player)
	sfx_player.play()


func play_ui_click() -> void:
	play_sfx(DEFAULT_UI_CLICK_SFX)


func _asegurar_buses_audio() -> void:
	_asegurar_bus(BUS_MUSICA)
	_asegurar_bus(BUS_SFX)
	_asegurar_bus(BUS_VOZ)


func _asegurar_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return

	AudioServer.add_bus()
	var ultimo_indice := AudioServer.bus_count - 1
	AudioServer.set_bus_name(ultimo_indice, bus_name)
	AudioServer.set_bus_send(ultimo_indice, BUS_MASTER)


func _aplicar_volumenes() -> void:
	for bus_name in volumenes.keys():
		_aplicar_volumen_bus(bus_name)


func _aplicar_volumen_bus(bus_name: String) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		push_warning("[AudioManager] No existe el bus: %s" % bus_name)
		return

	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volumenes[bus_name]))


func _guardar_configuracion_audio() -> void:
	var config := ConfigFile.new()
	for bus_name in volumenes.keys():
		config.set_value("audio", bus_name, volumenes[bus_name])
	config.save(SETTINGS_PATH)


func _cargar_configuracion_audio() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return

	for bus_name in volumenes.keys():
		if config.has_section_key("audio", bus_name):
			volumenes[bus_name] = clampf(float(config.get_value("audio", bus_name)), 0.0, 1.0)
