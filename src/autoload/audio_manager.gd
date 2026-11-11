extends Node

const BUS_MASTER := "Master"
const BUS_MUSICA := "Musica"
const BUS_SFX := "SFX"
const BUS_VOZ := "Voz"

const SETTINGS_PATH := "user://audio_settings.cfg"
const DEFAULT_UI_CLICK_SFX := "res://audios/sfx/ui_click.mp3"

var volumenes := {
	BUS_MASTER: 1.0,
	BUS_MUSICA: 0.8,
	BUS_SFX: 1.0,
	BUS_VOZ: 1.0,
}

var _reproductores_registrados: Array[Node] = []


func _init() -> void:
	# Creamos los buses en _init() para que existan antes del _ready() de cualquier escena o Autoload
	_asegurar_buses_audio()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_asegurar_buses_audio()
	_cargar_configuracion_audio()
	_aplicar_volumenes()

	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)
	_escanear_reproductores_existentes(get_tree().root)


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


func get_volumen_db(bus_name: String) -> float:
	var lin: float = get_volumen(bus_name)
	if lin <= 0.001:
		return -80.0
	return linear_to_db(lin)


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
	sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
	sfx_player.stream = stream
	sfx_player.bus = BUS_SFX
	sfx_player.set_meta("_base_volume_db", volume_db)
	sfx_player.volume_db = volume_db + get_volumen_db(BUS_SFX)
	sfx_player.pitch_scale = pitch_scale
	sfx_player.finished.connect(sfx_player.queue_free)
	add_child(sfx_player)
	_registrar_reproductor(sfx_player)
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
	if bus_idx != -1:
		if bus_name == BUS_MASTER:
			var silenciado: bool = volumenes[BUS_MASTER] <= 0.001
			AudioServer.set_bus_mute(bus_idx, silenciado)
			AudioServer.set_bus_volume_db(bus_idx, get_volumen_db(BUS_MASTER))
		else:
			# Mantenemos el sub-bus en 0 dB y aplicamos el volumen directamente a cada reproductor
			# para garantizar compatibilidad total en Web (HTML5) y escritorio sin duplicar atenuación.
			AudioServer.set_bus_mute(bus_idx, false)
			AudioServer.set_bus_volume_db(bus_idx, 0.0)

	if bus_name == BUS_MUSICA and MusicManager != null and MusicManager.has_method("actualizar_volumen_musica"):
		MusicManager.actualizar_volumen_musica()

	_actualizar_reproductores_registrados()


func _escanear_reproductores_existentes(raiz: Node) -> void:
	if raiz == null:
		return
	_on_node_added(raiz)
	for hijo in raiz.get_children():
		_escanear_reproductores_existentes(hijo)


func _on_node_added(node: Node) -> void:
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
		if node.has_meta("_ignorar_audio_manager"):
			return
		_registrar_reproductor(node)


func _registrar_reproductor(player: Node) -> void:
	if not is_instance_valid(player):
		return
	if not player.has_meta("_base_volume_db"):
		player.set_meta("_base_volume_db", float(player.get("volume_db")))
	if not _reproductores_registrados.has(player):
		_reproductores_registrados.append(player)
	_aplicar_volumen_a_reproductor(player)


func _actualizar_reproductores_registrados() -> void:
	var activos: Array[Node] = []
	for player in _reproductores_registrados:
		if is_instance_valid(player):
			_aplicar_volumen_a_reproductor(player)
			activos.append(player)
	_reproductores_registrados = activos


func _aplicar_volumen_a_reproductor(player: Node) -> void:
	if not is_instance_valid(player) or player.has_meta("_ignorar_audio_manager"):
		return
	var base_db: float = float(player.get_meta("_base_volume_db", 0.0))
	var bus_reproductor: String = String(player.get("bus"))
	if bus_reproductor == BUS_MUSICA or bus_reproductor == BUS_SFX or bus_reproductor == BUS_VOZ:
		player.set("volume_db", base_db + get_volumen_db(bus_reproductor))


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
