extends Node

const BUS_MUSICA := "Musica"

const AMBIENTE_MISTERIO := "misterio"
const AMBIENTE_TENSION := "tension"
const AMBIENTE_CALMA := "calma"
const AMBIENTE_TIERNURA := "ternura"

var _reproductor: AudioStreamPlayer
var _clave_actual: String = ""
var _override_dialogo_activo: String = ""
var _advertencias_emitidas: Dictionary[String, bool] = {}
var _ultima_ruta_escena: String = ""

var _pistas_por_clave: Dictionary[String, String] = {
	"menu_principal": "res://audios/musica/menu_principal.mp3",
	"personalizacion": "res://audios/musica/personalizacion.mp3",
	"mision_1": "res://audios/musica/mision_1.mp3",
	"mision_2": "res://audios/musica/mision_2.mp3",
	"mision_3": "res://audios/musica/mision_3.mp3",
	"mision_4": "res://audios/musica/mision_4.mp3",
	"transicion_llave": "res://audios/musica/transicion_llave.mp3",
	"cuestionario": "res://audios/musica/cuestionario.mp3",
	"resultado_final": "res://audios/musica/resultado_final.mp3",
	AMBIENTE_MISTERIO: "res://audios/musica/dialogo_misterio.mp3",
	AMBIENTE_TENSION: "res://audios/musica/dialogo_tension.mp3",
	AMBIENTE_CALMA: "res://audios/musica/dialogo_calma.mp3",
	AMBIENTE_TIERNURA: "res://audios/musica/dialogo_ternura.mp3",
	"mascota": "res://audios/musica/mascota.mp3",
	"inicio": "res://audios/musica/inicio.mp3",
	
	# --- NUEVAS CANCIONES REGISTRADAS ---
	"adivina": "res://audios/musica/adivina.mp3",
	"tutorial": "res://audios/musica/tutorial.mp3",
	"casa_embrujada": "res://audios/musica/casa_embrujada.mp3",
	"puerta1": "res://audios/musica/puerta1.mp3",
	"payaso": "res://audios/musica/payaso.mp3",
	"puerta": "res://audios/musica/puerta.mp3",
	"tunel": "res://audios/musica/tunel.mp3",
	"puerta3": "res://audios/musica/puerta3.mp3",
	"triste": "res://audios/musica/triste.mp3",
	"showman": "res://audios/musica/showman.mp3",
	"sentimental": "res://audios/musica/sentimental.mp3"
}

var _pistas_por_escena: Dictionary[String, String] = {
	
	# ==========================================
	# 1. MENÚS Y SELECCIÓN
	# ==========================================
	"res://scenes/menu_principal/menu_principal.tscn": "menu_principal",
	"res://scenes/intro_seleccion_genero/intro_seleccion_genero.tscn": "personalizacion",

	# ==========================================
	# 2. INTRODUCCIÓN A LA FERIA
	# ==========================================
	"res://scenes/intro_dialogo_1/intro_dialogo_1.tscn": "inicio",
	"res://scenes/intro_dialogo_2/intro_dialogo_2.tscn": "adivina",

	# ==========================================
	# 3. MISIÓN 1: PACMAN
	# ==========================================
	"res://scenes/mision_1_recoleccion/tutorial/scripts/Minijuego1_Tutorial.tscn": "tutorial",
	# (Mapas internos del Pacman)
	"res://scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn": "mision_1",
	"res://scenes/mision_1_recoleccion/mapa_2/mapa2.tscn": "mision_1",
	"res://scenes/mision_1_recoleccion/mapa_3/mapa3.tscn": "mision_1",
	"res://scenes/mision_1_recoleccion/mapa_4/mapa4.tscn": "mision_1",
	"res://scenes/mision_1_recoleccion/mapa_5/mapa5.tscn": "mision_1",

	# ==========================================
	# 4. CUESTIONARIOS Y LLAVE 1
	# ==========================================
	"res://scenes/cuestionarios/EscenaCuestionario.tscn": "cuestionario",
	"res://scenes/transicion_post_mision_1/transicion_post_mision_1.tscn": "transicion_llave",

	# ==========================================
	# 5. CASA EMBRUJADA Y PERRO
	# ==========================================
	"res://scenes/intro_dialogo_3/intro_dialogo_3.tscn": "casa_embrujada", # Casa embrujada (id3)
	"res://scenes/intro_dialogo_4/intro_dialogo_4.tscn": "puerta1", # Puerta embrujada (id4)
	"res://scenes/intro_dialogo_5/intro_dialogo_5.tscn": AMBIENTE_TENSION, # Perro encuentro (id5)

	# ==========================================
	# 6. MISIÓN 2: EMOCIONES
	# ==========================================
	"res://scenes/intro_mision_2/intro_mision_2.tscn": "payaso", # Misión emociones intro
	"res://scenes/mision_2_memorias/tutorial/scripts/Minijuego2_Tutorial.tscn": "tutorial",
	"res://scenes/mision_2_memorias/mision_2_memorias.tscn": "mision_2",
	
	# ==========================================
	# 7. LLAVE 2
	# ==========================================
	"res://scenes/transicion_post_mision_2/transicion_post_mision_2.tscn": "transicion_llave",

	# ==========================================
	# 8. MAZMORRA Y HACHAS
	# ==========================================
	"res://scenes/intro_dialogo_6/intro_dialogo_6.tscn": "puerta", # Puerta mazmorra (id6)
	"res://scenes/intro_dialogo_7/intro_dialogo_7.tscn": "tunel", # Pasillo con parca (id7)
	"res://scenes/mision_3_nuevo/tutorial/Minijuego3_Tutorial.tscn": "tutorial", # Tuto hachas
	"res://scenes/mision_3_nuevo/minijuego3.tscn": "mision_3", # Minijuego hachas

	# ==========================================
	# 9. LLAVE 3
	# ==========================================
	"res://scenes/recompensa_mision_3/recompensa_mision_3.tscn": "transicion_llave",

	# ==========================================
	# 10. CEMENTERIO Y TOPOS
	# ==========================================
	"res://scenes/intro_dialogo_8/intro_dialogo_8.tscn": "puerta3", # Puerta cementerio (id8)
	"res://scenes/intro_dialogo_9/intro_dialogo_9.tscn": "triste", # Cementerio (id9)
	"res://scenes/mision_4_payasos/tutorial/Minijuego4_Tutorial.tscn": "tutorial", # Tuto topos
	"res://scenes/mision_4_payasos/mapa_topos.tscn": "mision_4", # Minijuego topos

	# ==========================================
	# 11. CIERRE: ROBO Y REUNIÓN
	# ==========================================
	"res://scenes/intro_dialogo_10/intro_dialogo_10.tscn": "showman", # Mago roba Perro (id10)
	"res://scenes/intro_dialogo_12/intro_dialogo_12.tscn": "sentimental", # Reunion con Perro (id12)

	# ==========================================
	# 12. FINAL Y REJUGABILIDAD
	# ==========================================
	"res://scenes/final/resultado_final.tscn": "resultado_final",
	"res://scenes/rejugabilidad/mapa_rejugabilidad.tscn": "tutorial"
}

func _ready() -> void:
	_reproductor = AudioStreamPlayer.new()
	_reproductor.name = "MusicPlayer"
	_reproductor.bus = _obtener_bus_musica()
	add_child(_reproductor)
	
	_validar_pistas_registradas()

	if get_tree().has_signal("current_scene_changed"):
		get_tree().current_scene_changed.connect(_on_current_scene_changed)

	_actualizar_musica_escena_actual()
	set_process(true)


func reproducir_dialogo_por_ambiente(ambiente: String) -> void:
	iniciar_override_dialogo(ambiente)


func _process(_delta: float) -> void:
	if _override_dialogo_activo.is_empty():
		_actualizar_musica_si_cambio_escena()


func _actualizar_musica_si_cambio_escena() -> void:
	var escena_actual: Node = get_tree().current_scene
	if escena_actual == null:
		return

	var ruta_escena: String = escena_actual.scene_file_path
	if ruta_escena.is_empty() or ruta_escena == _ultima_ruta_escena:
		return

	_ultima_ruta_escena = ruta_escena
	_actualizar_musica_escena_actual(false)


func iniciar_override_dialogo(ambiente: String) -> void:
	if ambiente.is_empty():
		return

	_override_dialogo_activo = ambiente
	# Usamos la función original de reproducir_clave, pero con fade
	reproducir_clave(ambiente)


func finalizar_override_dialogo() -> void:
	if _override_dialogo_activo.is_empty():
		restaurar_tema_escena_actual()
		return

	_override_dialogo_activo = ""
	restaurar_tema_escena_actual()


func restaurar_tema_escena_actual() -> void:
	_actualizar_musica_escena_actual(true)


# --- NUEVA VERSIÓN CON FADE ---
func reproducir_desde_ruta(ruta_pista: String, from_position: float = 0.0, tiempo_fade: float = 1.0, forzar_reinicio: bool = false) -> void:
	if ruta_pista.is_empty():
		return

	if not ResourceLoader.exists(ruta_pista):
		push_warning("[MusicManager] Falta archivo de música: %s" % ruta_pista)
		return

	var stream := load(ruta_pista) as AudioStream
	if stream == null:
		push_warning("[MusicManager] No se pudo cargar el AudioStream: %s" % ruta_pista)
		return

	if _reproductor.stream == stream and _reproductor.playing and not forzar_reinicio:
		return

	_clave_actual = ""
	_transicionar_musica(stream, from_position, tiempo_fade)


# --- NUEVA VERSIÓN CON FADE ---
func reproducir_clave(clave: String, from_position: float = 0.0, tiempo_fade: float = 1.0, forzar_reinicio: bool = false) -> void:
	# Si forzamos reinicio, ignoramos que sea la misma clave
	if _clave_actual == clave and not forzar_reinicio:
		return

	var ruta_pista: String = _pistas_por_clave.get(clave, "")
	if ruta_pista.is_empty():
		push_warning("[MusicManager] No existe una pista registrada para la clave '%s'" % clave)
		return

	if not ResourceLoader.exists(ruta_pista):
		if not _advertencias_emitidas.has(clave):
			_advertencias_emitidas[clave] = true
			push_warning("[MusicManager] Falta archivo de música para '%s': %s" % [clave, ruta_pista])
		return

	var stream := load(ruta_pista) as AudioStream
	if stream == null:
		push_warning("[MusicManager] No se pudo cargar el AudioStream: %s" % ruta_pista)
		return

	_clave_actual = clave
	_transicionar_musica(stream, from_position, tiempo_fade)


# --- FUNCIÓN INTERNA DE TRANSICIÓN SUAVE ---
func _transicionar_musica(nuevo_stream: AudioStream, from_position: float, tiempo_fade: float) -> void:
	if tiempo_fade <= 0.0:
		_reproductor.volume_db = 0.0
		_reproductor.stream = nuevo_stream
		_reproductor.play(from_position)
		return
		
	if _reproductor.playing:
		var tween = create_tween()
		tween.tween_property(_reproductor, "volume_db", -60.0, tiempo_fade / 2.0)
		tween.tween_callback(func():
			_reproductor.stream = nuevo_stream
			_reproductor.play(from_position)
		)
		tween.tween_property(_reproductor, "volume_db", 0.0, tiempo_fade / 2.0)
	else:
		_reproductor.volume_db = -60.0
		_reproductor.stream = nuevo_stream
		_reproductor.play(from_position)
		var tween = create_tween()
		tween.tween_property(_reproductor, "volume_db", 0.0, tiempo_fade)


# Detiene la música cortando de golpe
func detener() -> void:
	_clave_actual = ""
	_override_dialogo_activo = ""
	_reproductor.stop()

# Apaga la música suavemente
func detener_suave(tiempo_fade: float = 1.0) -> void:
	if _reproductor.playing:
		_clave_actual = ""
		_override_dialogo_activo = ""
		var tween = create_tween()
		tween.tween_property(_reproductor, "volume_db", -60.0, tiempo_fade)
		tween.tween_callback(_reproductor.stop)


func _on_current_scene_changed(_nueva_escena: Node) -> void:
	_actualizar_musica_escena_actual(false)


func _actualizar_musica_escena_actual(forzar_restauracion: bool = false) -> void:
	var escena_actual: Node = get_tree().current_scene
	if escena_actual == null:
		return

	var ruta_escena: String = escena_actual.scene_file_path
	if ruta_escena.is_empty():
		return
		
	_ultima_ruta_escena = ruta_escena

	var clave: String = _pistas_por_escena.get(ruta_escena, "")
	if ruta_escena.begins_with("res://scenes/mision_3_hachas/nivel"):
		clave = "mision_3"
	if clave.is_empty():
		return

	if not _override_dialogo_activo.is_empty() and not forzar_restauracion:
		return

	# Al cambiar de escena, el script llama automáticamente a reproducir con el Fade predeterminado de 1.0 seg
	reproducir_clave(clave)


func _validar_pistas_registradas() -> void:
	var faltantes: Dictionary[String, PackedStringArray] = {}
	for clave in _pistas_por_clave.keys():
		var ruta: String = _pistas_por_clave[clave]
		if ResourceLoader.exists(ruta):
			continue
		var extension := ruta.get_extension().to_lower()
		if not faltantes.has(extension):
			faltantes[extension] = PackedStringArray()
		faltantes[extension].append("%s -> %s" % [clave, ruta])

	if faltantes.is_empty():
		return

	var detalles := PackedStringArray()
	for extension in faltantes.keys():
		detalles.append("%s: [%s]" % [extension, ", ".join(faltantes[extension])])

	push_warning("[MusicManager] Pistas faltantes al iniciar: %s" % " | ".join(detalles))


func _obtener_bus_musica() -> String:
	if AudioManager == null:
		return BUS_MUSICA

	if AudioManager.BUS_MUSICA != BUS_MUSICA:
		push_warning("[MusicManager] BUS_MUSICA no coincide con AudioManager (%s != %s). Se usará '%s'." % [BUS_MUSICA, AudioManager.BUS_MUSICA, AudioManager.BUS_MUSICA])
	return AudioManager.BUS_MUSICA
