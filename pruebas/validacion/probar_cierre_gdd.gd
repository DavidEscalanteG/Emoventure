extends SceneTree

var fallos: int = 0
var comprobaciones: int = 0

func _initialize() -> void:
	call_deferred("_ejecutar")

func _comprobar(condicion: bool, mensaje: String) -> void:
	comprobaciones += 1
	if not condicion:
		fallos += 1
		push_error(mensaje)

func _abrir(ruta: String) -> void:
	change_scene_to_file(ruta)
	await scene_changed
	await process_frame
	await process_frame

func _contaminar_estado() -> void:
	var jugador: GDScript = load("res://scenes/mision_3_nuevo/jugador.gd")
	var payasos: GDScript = load("res://scenes/mision_4_payasos/mapa_topos.gd")
	jugador.hay_checkpoint = true
	jugador.pos_checkpoint = Vector2(6300, 460)
	jugador.tiempo_musica_checkpoint = 32.0
	jugador.contador_muertes = 9
	payasos.intentos_mision_4 = 4

func _comprobar_estado_limpio(contexto: String) -> void:
	var jugador: GDScript = load("res://scenes/mision_3_nuevo/jugador.gd")
	var payasos: GDScript = load("res://scenes/mision_4_payasos/mapa_topos.gd")
	_comprobar(not jugador.hay_checkpoint and jugador.pos_checkpoint == Vector2.ZERO, contexto + ": sin checkpoint heredado")
	_comprobar(jugador.contador_muertes == 0 and jugador.tiempo_musica_checkpoint == 0.0, contexto + ": sin muertes ni música heredadas")
	_comprobar(payasos.intentos_mision_4 == 0, contexto + ": sin intentos de payasos heredados")

func _ejecutar() -> void:
	# El guardado automático se desactiva y no se invocan métodos que escriban slots.
	var guardados: Node = root.get_node("SaveManager")
	guardados.set_process(false)
	guardados.current_slot_id = ""
	await _probar_arranque()
	await _probar_estado(guardados)
	await _probar_payasos()
	await _probar_resultados()
	if current_scene != null:
		current_scene.queue_free()
	await process_frame
	root.get_node("MusicManager").detener()
	await create_timer(0.3).timeout
	print("CIERRE GDD: %d comprobaciones, %d fallos" % [comprobaciones, fallos])
	quit(0 if fallos == 0 else 1)

func _probar_arranque() -> void:
	await _abrir("res://scenes/PantallaWeb.tscn")
	await process_frame
	if not OS.has_feature("web"):
		_comprobar(current_scene.scene_file_path == "res://scenes/menu_principal/menu_principal.tscn", "Arranque fuera de Web llega al menú sin cambiar el árbol durante _ready")

func _probar_estado(guardados: Node) -> void:
	var manager: Node = root.get_node("GameManager")
	_contaminar_estado()
	manager.activar_modo_rejugabilidad()
	_comprobar_estado_limpio("Nuevo recorrido de rejugabilidad")
	_contaminar_estado()
	guardados._estado_cuestionario_pendiente = {"dimension": "atencion"}
	guardados.preparar_nueva_partida()
	_comprobar_estado_limpio("Nueva partida")
	_comprobar(not manager.consumir_modo_rejugabilidad(), "Nueva partida no hereda modo de rejugabilidad")
	_comprobar(guardados.obtener_estado_cuestionario_pendiente().is_empty(), "Nueva partida no hereda cuestionario")
	await _abrir("res://scenes/mision_3_nuevo/minijuego3.tscn")
	var jugador: CharacterBody2D = current_scene.get_node("Jugador")
	jugador.set_physics_process(false)
	_comprobar(jugador.global_position.x < 1000.0, "Nueva partida comienza al inicio de M3")
	jugador.registrar_checkpoint(Vector2(6300, 460), 12.0)
	jugador.contador_muertes = 3
	reload_current_scene()
	await scene_changed
	await process_frame
	jugador = current_scene.get_node("Jugador")
	jugador.set_physics_process(false)
	_comprobar(jugador.global_position.x >= 6300.0 and jugador.contador_muertes == 3, "Reintentar el mismo recorrido conserva checkpoint y muertes")
	# Cargar un slot se prueba con datos en memoria, sin escribir partidas reales.
	var originales: Array = guardados._partidas
	guardados._partidas = [{"id": "revision", "escena_actual": "res://scenes/menu_principal/menu_principal.tscn",
		"puntajes_emocionales": {"atencion": 20, "claridad": 25, "reparacion": 30},
		"estado_cuestionario": {"dimension": "claridad"}}]
	_contaminar_estado()
	_comprobar(guardados.cargar_partida("revision"), "Carga de slot válido")
	_comprobar_estado_limpio("Cambiar de partida")
	_comprobar(guardados.obtener_estado_cuestionario_pendiente().get("dimension") == "claridad", "Carga restaura su propio cuestionario")
	_comprobar(manager.obtener_puntajes_por_dimension().reparacion == 30, "Carga conserva los puntajes del slot")
	guardados.current_slot_id = ""
	guardados._partidas = originales
	await scene_changed
	await process_frame
	guardados.preparar_nueva_partida()

func _probar_payasos() -> void:
	await _abrir("res://scenes/mision_4_payasos/mapa_topos.tscn")
	var mision: Node = current_scene
	mision.get_node("SpawnTimer").stop()
	mision.get_node("TimerJuego").stop()
	_comprobar(mision.umbral_puntos_victoria == 40 and mision.umbral_porcentaje_aciertos_victoria == 0.5, "Conserva umbrales aprobados de 40 puntos o 50 por ciento")
	_comprobar(mision.intentos_mision_4 == 1 and not mision.boton_saltar_hud.visible, "Primer intento no permite omitir")
	for intento: int in range(2, 5):
		mision._reiniciar_mision()
		mision.get_node("SpawnTimer").stop()
		mision.get_node("TimerJuego").stop()
		_comprobar(mision.intentos_mision_4 == intento, "Reintento contabilizado una sola vez")
		_comprobar(mision.boton_saltar_hud.visible == (intento >= 4), "Omisión desde cuarto intento")
	for topo: Node in mision.topos_jugables:
		topo.show()
	mision.total_topos_aparecidos = 0
	mision._on_spawn_timer_timeout()
	_comprobar(mision.total_topos_aparecidos == 0, "Payasos ya visibles no generan apariciones ficticias")
	for topo: Node in mision.topos_jugables:
		topo.reset_estado()
	mision.dificultad = 3.0
	mision._on_spawn_timer_timeout()
	_comprobar(mision.total_topos_aparecidos == 3, "Tres huecos libres generan tres apariciones reales")
	var visibles: Array = mision.topos_jugables.filter(func(topo: Node) -> bool: return topo.visible)
	var objetivo: Node = visibles[0]
	_comprobar(not objetivo.aparecer(), "Reaparecer mientras es visible se rechaza")
	objetivo.golpeado()
	objetivo.golpeado()
	_comprobar(mision.puntos == 1, "Doble golpe en la misma aparición cuenta una sola vez")
	# Un reinicio durante la bajada no debe dejar un callback que oculte al siguiente payaso.
	objetivo.reset_estado()
	objetivo.get_node("Timer").wait_time = 5.0
	_comprobar(objetivo.aparecer(), "Payaso vuelve a estar disponible tras reset")
	await create_timer(0.9).timeout
	_comprobar(objetivo.visible, "Animación antigua no oculta una aparición nueva")
	objetivo.reset_estado()
	mision.puntos = 40
	mision.total_topos_aparecidos = 100
	_comprobar(mision._evaluar_resultado().victoria, "40 puntos permiten ganar")
	mision.puntos = 39
	_comprobar(not mision._evaluar_resultado().victoria, "39 puntos y precisión insuficiente no ganan")
	mision.puntos = 10
	mision.total_topos_aparecidos = 20
	_comprobar(mision._evaluar_resultado().victoria, "50 por ciento exacto permite ganar")
	mision.puntos = 9
	_comprobar(not mision._evaluar_resultado().victoria, "Menos de 50 por ciento no gana sin puntos suficientes")
	mision.puntos = 0
	mision.total_topos_aparecidos = 0
	_comprobar(not mision._evaluar_resultado().victoria, "Sin apariciones ni puntos no gana")
	mision._on_boton_saltar_hud_pressed()
	mision._on_boton_saltar_hud_pressed()
	await process_frame
	_comprobar(current_scene.has_method("responder"), "Omisión conduce al cuestionario una sola vez")
	_comprobar(current_scene.preguntas.size() == 4 and current_scene.dimension == "reparacion", "Omisión conserva las cuatro preguntas de reparación")
	var payasos: GDScript = load("res://scenes/mision_4_payasos/mapa_topos.gd")
	_comprobar(payasos.intentos_mision_4 == 0, "Salir de M4 reinicia los intentos")

func _probar_resultados() -> void:
	await _abrir("res://scenes/final/resultado_final.tscn")
	var datos: Node = root.get_node("DatosJugador")
	var limites: Dictionary = {
		"hombre": {"atencion": [21, 32], "claridad": [25, 35], "reparacion": [23, 35]},
		"mujer": {"atencion": [24, 35], "claridad": [23, 34], "reparacion": [23, 34]}
	}
	var mensajes: Dictionary = {
		"atencion": ["Debe mejorar su atención: presta poca atención.", "Adecuada atención.", "Debe mejorar su atención: presta demasiada atención."],
		"claridad": ["Debe mejorar su claridad emocional.", "Adecuada claridad emocional.", "Excelente claridad emocional."],
		"reparacion": ["Debe mejorar su reparación de las emociones.", "Adecuada reparación de las emociones.", "Excelente reparación de las emociones."]
	}
	for genero: String in limites:
		datos.genero = genero
		for dimension: String in limites[genero]:
			for puntaje: int in range(8, 41):
				var fronteras: Array = limites[genero][dimension]
				var categoria: int = 0 if puntaje <= fronteras[0] else (1 if puntaje <= fronteras[1] else 2)
				_comprobar(current_scene._obtener_mensaje_dimension(dimension, puntaje) == mensajes[dimension][categoria],
					"%s %s %d: interpretación inclusiva correcta" % [genero, dimension, puntaje])
	var puntajes: Dictionary[String, int] = {"atencion": 24, "claridad": 24, "reparacion": 24}
	_comprobar(current_scene._construir_texto_perfil_final(puntajes, 72).contains("misma puntuación"), "Empate triple explícito")
	puntajes.atencion = 8
	var perfil: String = current_scene._construir_texto_perfil_final(puntajes, 56)
	_comprobar(perfil.contains("Claridad emocional y Reparación emocional"), "Empate doble nombra ambas dimensiones")
	puntajes.claridad = 40
	_comprobar(current_scene._construir_texto_perfil_final(puntajes, 72).begins_with("La puntuación más alta fue en Claridad emocional."), "Máximo único correcto")
	var captura: String = OS.get_environment("CODEX_CIERRE_CAPTURA")
	if not captura.is_empty():
		datos.genero = "mujer"
		root.get_node("GameManager").cargar_puntajes_desde_guardado(0, {"atencion": 36, "claridad": 23, "reparacion": 35})
		current_scene._renderizar_resumen()
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		_comprobar(root.get_texture().get_image().save_png(captura) == OK, "Captura de resultados con fronteras por género")

