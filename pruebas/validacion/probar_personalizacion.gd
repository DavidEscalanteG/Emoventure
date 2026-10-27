extends SceneTree

## Ejecutar con Godot --headless --path . --script res://pruebas/validacion/probar_personalizacion.gd
## Solo cambia la apariencia en memoria; no crea ni confirma partidas.
var fallos: int = 0
var comprobaciones: int = 0


func _initialize() -> void:
	call_deferred("_ejecutar")


func _comprobar(condicion: bool, mensaje: String) -> void:
	comprobaciones += 1
	if condicion:
		print("OK: ", mensaje)
	else:
		fallos += 1
		push_error("FALLO: " + mensaje)


func _pulsar_raton(posicion: Vector2, presionado: bool) -> void:
	var evento: InputEventMouseButton = InputEventMouseButton.new()
	evento.position = posicion
	evento.global_position = posicion
	evento.button_index = MOUSE_BUTTON_LEFT
	evento.button_mask = MOUSE_BUTTON_MASK_LEFT if presionado else 0
	evento.pressed = presionado
	# Las posiciones de Control ya están en coordenadas lógicas del viewport.
	root.push_input(evento, true)


func _ejecutar() -> void:
	root.size = Vector2i(1920, 1080)
	var datos: Node = root.get_node("DatosJugador")
	var guardados: Node = root.get_node("SaveManager")
	var apariencia_inicial: Resource = load("res://src/autoload/estado/apariencia_jugador.gd").new()
	_comprobar(apariencia_inicial.color_cuerpo == Color("d89878"), "La piel inicial usa el tono medio de los sprites originales")
	_comprobar(apariencia_inicial.color_boca == apariencia_inicial.COLOR_ROPA_INICIAL, "Conserva el color de ropa inicial configurado")
	_comprobar(apariencia_inicial.color_cabello == apariencia_inicial.COLOR_CABELLO_INICIAL, "Conserva el color de cabello inicial configurado")
	guardados._aplicar_apariencia_desde_diccionario({"color_boca": "ffffffff", "color_cuerpo": "004488ff"})
	_comprobar(datos.apariencia.color_boca == Color.WHITE and datos.apariencia.color_cuerpo == Color("004488"), "Cargar respeta los colores elegidos, incluido el blanco")
	guardados._aplicar_apariencia_desde_diccionario({})
	_comprobar(datos.apariencia.color_cuerpo == apariencia_inicial.color_cuerpo and datos.apariencia.color_boca == apariencia_inicial.color_boca, "Un guardado sin colores usa los nuevos valores iniciales")
	var colores: Dictionary = {
		"color_cabello": Color.from_hsv(0.12, 0.65, 0.72),
		"color_boca": Color.from_hsv(0.36, 0.55, 0.82),
		"color_cuerpo": Color.from_hsv(0.08, 0.38, 0.93),
		"color_cabeza": Color.from_hsv(0.62, 0.45, 0.67),
	}
	for clave: String in colores:
		datos.set_color_apariencia(clave, colores[clave])
	change_scene_to_file("res://scenes/personalizacion/Personalizacion.tscn")
	await scene_changed
	for cuadro: int in range(4):
		await process_frame
	var contenedor: VBoxContainer = current_scene.get_node("%HSVColorEditor")
	var apariencia: Node2D = current_scene.get_node("Jugador/PlayerAppearance")
	_comprobar(not current_scene.get_node("Jugador").mostrar_controles_moviles, "El preview no añade una cruceta sobre la personalización en móvil")
	var secciones: Dictionary = {
		"HSVEditorCabello": "Cabello", "HSVEditorRopa": "Boca",
		"HSVEditorPiel": "Cuerpo", "HSVEditorGorro": "Cabeza",
	}
	for nombre: String in secciones:
		var editor: PanelContainer = contenedor.get_node(nombre)
		var material_esperado: Material = apariencia.MATERIAL_COLOR_PIEL if nombre == "HSVEditorPiel" else apariencia.MATERIAL_COLOR_NEUTRO
		_comprobar(apariencia.get_node(secciones[nombre]).material == material_esperado, nombre + ": usa el material de color de su sección")
		var inicial: Color = colores[editor.clave_color_global]
		_comprobar(is_equal_approx(editor.slider_h.value, snappedf(inicial.h, 0.001)), nombre + ": recupera el tono existente")
		_comprobar(is_equal_approx(editor.slider_s.value, snappedf(inicial.s, 0.001)), nombre + ": recupera la saturación existente")
		_comprobar(is_equal_approx(editor.slider_v.value, snappedf(inicial.v, 0.001)), nombre + ": recupera el brillo existente")
		var otros_colores: Dictionary = {}
		for clave: String in colores:
			otros_colores[clave] = datos.obtener_color_apariencia(clave)
		editor.slider_h.value = 0.42
		editor.slider_s.value = 0.68
		editor.slider_v.value = 0.81
		var esperado: Color = Color.from_hsv(0.42, 0.68, 0.81)
		_comprobar(datos.obtener_color_apariencia(editor.clave_color_global).is_equal_approx(esperado), nombre + ": actualiza la apariencia global")
		_comprobar(apariencia.get_node(secciones[nombre]).self_modulate.is_equal_approx(esperado), nombre + ": actualiza el personaje en tiempo real")
		for clave: String in colores:
			if clave != editor.clave_color_global:
				_comprobar(datos.obtener_color_apariencia(clave).is_equal_approx(otros_colores[clave]), nombre + ": conserva " + clave)
		_comprobar(editor.valor_h.text == "151°" and editor.valor_s.text == "68%" and editor.valor_v.text == "81%", nombre + ": muestra los valores actuales")
		_comprobar(editor.muestra.get_theme_stylebox("panel").bg_color.is_equal_approx(esperado), nombre + ": muestra el color elegido")
		editor.slider_v.value = 0.0
		_comprobar(is_equal_approx(editor.slider_v.value, 0.125), nombre + ": mantiene el límite de brillo")
		editor.slider_v.value = 0.81
		if editor.visible:
			_comprobar(editor.get_global_rect().end.y < 1080.0, nombre + ": panel completo dentro de pantalla")

	var cabello: PanelContainer = contenedor.get_node("HSVEditorCabello")
	var barra: HSlider = cabello.slider_h
	barra.grab_focus()
	var anterior: float = barra.value
	var tecla: InputEventAction = InputEventAction.new()
	tecla.action = &"ui_right"
	tecla.pressed = true
	root.push_input(tecla)
	tecla.pressed = false
	root.push_input(tecla)
	_comprobar(barra.value > anterior, "El teclado permite ajustar la barra enfocada")
	var inicio: Vector2 = barra.global_position + Vector2(barra.size.x * 0.3, barra.size.y * 0.5)
	_pulsar_raton(inicio, true)
	var tras_pulsar: float = barra.value
	var movimiento: InputEventMouseMotion = InputEventMouseMotion.new()
	movimiento.position = inicio + Vector2(barra.size.x * 0.3, 0)
	movimiento.global_position = movimiento.position
	movimiento.relative = Vector2(barra.size.x * 0.3, 0)
	movimiento.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(movimiento)
	_pulsar_raton(movimiento.position, false)
	_comprobar(barra.value > tras_pulsar, "El arrastre modifica el color")
	_comprobar(apariencia.get_node("Cabello").self_modulate.is_equal_approx(datos.obtener_color_apariencia("color_cabello")), "El arrastre actualiza el personaje")
	var color_conservado: Color = datos.obtener_color_apariencia("color_cabello")
	change_scene_to_file("res://scenes/personalizacion/Personalizacion.tscn")
	await scene_changed
	await process_frame
	cabello = current_scene.get_node("%HSVColorEditor/HSVEditorCabello")
	_comprobar(cabello.muestra.get_theme_stylebox("panel").bg_color.is_equal_approx(color_conservado), "Al reabrir recupera el color editado")
	await _probar_distribucion()
	await _probar_retratos()
	current_scene.queue_free()
	await process_frame
	root.get_node("MusicManager").detener()
	await create_timer(0.25).timeout
	print("PERSONALIZACION: %d comprobaciones, %d fallos" % [comprobaciones, fallos])
	quit(0 if fallos == 0 else 1)


func _probar_distribucion() -> void:
	var datos: Node = root.get_node("DatosJugador")
	datos.apariencia = load("res://src/autoload/estado/apariencia_jugador.gd").new()
	change_scene_to_file("res://scenes/personalizacion/Personalizacion.tscn")
	await scene_changed
	var capturas: String = OS.get_environment("CODEX_PERSONALIZACION_CAPTURE_DIR")
	if not capturas.is_empty():
		DirAccess.make_dir_recursive_absolute(capturas)
	for tamano: Vector2i in [Vector2i(1920, 1080), Vector2i(854, 480), Vector2i(640, 360)]:
		root.size = tamano
		for cuadro: int in range(4):
			await process_frame
		var pantalla: Rect2 = root.get_visible_rect()
		var panel: PanelContainer = current_scene.get_node("%PanelLateral")
		_comprobar(pantalla.encloses(panel.get_global_rect()), "Panel lateral completo dentro de " + str(tamano))
		_comprobar(panel.get_global_rect().position.x >= pantalla.size.x * 0.65, "Al menos el 65% de la escena queda libre de paneles")
		for control: String in ["InputNombreJugador", "BtnCabelloAtras", "BtnCabelloSiguiente", "MascotaAnterior", "MascotaSiguiente", "Comenzar"]:
			_comprobar(panel.get_global_rect().encloses(current_scene.get_node("%" + control).get_global_rect()), "Control dentro del panel lateral: " + control)
		for seccion: String in ["Cabello", "Ropa", "Piel"]:
			var boton: Button = current_scene.get_node("%HSVColorEditor/PestanasColor/" + seccion)
			_pulsar_raton(boton.get_global_rect().get_center(), true)
			_pulsar_raton(boton.get_global_rect().get_center(), false)
			for cuadro: int in range(4):
				await process_frame
			var editor: PanelContainer = current_scene.get_node("%HSVColorEditor/HSVEditor" + seccion)
			_comprobar(editor.visible and boton.button_pressed, "%s: clic abre %s" % [tamano, seccion])
			var visibles: int = 0
			for nombre: String in ["Cabello", "Ropa", "Piel"]:
				if current_scene.get_node("%HSVColorEditor/HSVEditor" + nombre).visible:
					visibles += 1
			_comprobar(visibles == 1, "Solo se muestra un editor de color a la vez")
			_comprobar(pantalla.encloses(editor.get_global_rect()), "El editor completo cabe en " + str(tamano))
			for grupo: String in ["Tono", "Saturacion", "Brillo"]:
				var etiqueta: Label = editor.get_node("Contenido/" + grupo + "/Encabezado/Nombre")
				_comprobar(etiqueta.get_theme_font_size("font_size") >= 36 and pantalla.encloses(etiqueta.get_global_rect()), "Etiqueta legible y dentro de pantalla: " + grupo)
			for barra: HSlider in [editor.slider_h, editor.slider_s, editor.slider_v]:
				_comprobar(barra.size.y >= 64 and panel.get_global_rect().encloses(barra.get_global_rect()), "Barra accesible y dentro del panel")
				_comprobar(not barra.tooltip_text.is_empty(), "La explicación sigue disponible al señalar la barra")
			_comprobar(pantalla.encloses(current_scene.get_node("%Comenzar").get_global_rect()), "Comenzar siempre visible")
			if not capturas.is_empty() and DisplayServer.get_name() != "headless":
				# Deja completar el primer dibujado de los controles antes de leer la GPU.
				await create_timer(0.1).timeout
				await RenderingServer.frame_post_draw
				var ruta: String = capturas.path_join("%dx%d_%s.png" % [tamano.x, tamano.y, seccion.to_lower()])
				_comprobar(root.get_texture().get_image().save_png(ruta) == OK, "Captura guardada")
		var nombre: LineEdit = current_scene.input_nombre_jugador
		nombre.text = ""
		var comenzar: Button = current_scene.get_node("%Comenzar")
		_pulsar_raton(comenzar.get_global_rect().get_center(), true)
		_pulsar_raton(comenzar.get_global_rect().get_center(), false)
		await create_timer(0.8).timeout
		_comprobar(not current_scene.label_error_nombre_jugador.text.is_empty(), "La validación del nombre sigue activa")
		_comprobar(current_scene.panel_nombre_jugador.get_global_rect().encloses(current_scene.label_error_nombre_jugador.get_global_rect()), "El mensaje de nombre cabe en su panel")
		_comprobar(pantalla.encloses(panel.get_global_rect()), "La validación no desplaza el panel fuera de pantalla")
		current_scene.label_error_nombre_jugador.text = ""
		await _probar_selectores()


func _probar_selectores() -> void:
	var datos: Node = root.get_node("DatosJugador")
	var indice: int = datos.apariencia.indice_cabello
	for boton: String in ["BtnCabelloSiguiente", "BtnCabelloAtras"]:
		var control: Button = current_scene.get_node("%" + boton)
		_pulsar_raton(control.get_global_rect().get_center(), true)
		_pulsar_raton(control.get_global_rect().get_center(), false)
		await process_frame
		if boton == "BtnCabelloSiguiente":
			_comprobar(datos.apariencia.indice_cabello != indice, "El clic cambia el peinado")
	_comprobar(datos.apariencia.indice_cabello == indice, "El botón anterior recupera el peinado")
	var apariencia: Node = current_scene.apariencia
	for pieza: String in ["Cuerpo", "Cabello"]:
		var retrato: Sprite2D = current_scene.get_node("%" + pieza)
		var original: AnimatedSprite2D = apariencia.get_node(pieza)
		if pieza == "Cabello":
			_comprobar(retrato.texture.atlas == original.sprite_frames.get_frame_texture("idle_down", 0), "Miniatura usa el cabello elegido")
		else:
			var cabeza: Image = retrato.texture.atlas.get_image()
			var cuerpo: Image = original.sprite_frames.get_frame_texture("idle_down", 0).get_image()
			_comprobar(cabeza.get_pixel(31, 27) == cuerpo.get_pixel(31, 27), "La cabeza conserva la nariz y la barbilla originales")
			_comprobar(cabeza.get_pixel(37, 27).a == 0.0 and cabeza.get_pixel(26, 30).a == 0.0, "La miniatura excluye hombros y brazos")
		_comprobar(retrato.self_modulate.is_equal_approx(original.self_modulate), "Miniatura conserva el color elegido: " + pieza)
	var indice_mascota: int = datos.obtener_indice_mascota()
	for boton: String in ["MascotaSiguiente", "MascotaAnterior"]:
		var control: Button = current_scene.get_node("%" + boton)
		for paso: int in range(current_scene.mascota.coleccion_mascotas.size()):
			var anterior: int = datos.obtener_indice_mascota()
			_pulsar_raton(control.get_global_rect().get_center(), true)
			_pulsar_raton(control.get_global_rect().get_center(), false)
			await process_frame
			_comprobar(datos.obtener_indice_mascota() != anterior, "El selector cambia de mascota")
			var miniatura: TextureRect = current_scene.get_node("%MiniaturaMascota")
			_comprobar(miniatura.texture.region.size.x > 0 and miniatura.texture.region.size.y > 0, "Perros y gatos tienen miniatura visible")
			var sprite: AnimatedSprite2D = current_scene.mascota.sprite
			_comprobar(miniatura.texture.atlas == sprite.sprite_frames.get_frame_texture(sprite.animation, 0), "Miniatura y escenario muestran la misma mascota")
	_comprobar(datos.obtener_indice_mascota() == indice_mascota, "Ambos selectores de mascota completan el ciclo")


func _probar_retratos() -> void:
	var datos: Node = root.get_node("DatosJugador")
	var area: Control = current_scene.get_node("%RetratoPeinado")
	var retrato: Node2D = current_scene.get_node("%Retrato")
	for genero: String in ["hombre", "mujer"]:
		datos.genero = genero
		var rango: Vector2i = datos.obtener_rango_cabello_por_genero(genero)
		for indice: int in range(rango.x, rango.y + 1):
			current_scene.indice_cabello = indice
			current_scene.refrescar_preview()
			await process_frame
			var limites: Rect2 = Rect2()
			for pieza: String in ["Cuerpo", "Cabello"]:
				var sprite: Sprite2D = current_scene.get_node("%" + pieza)
				if not sprite.visible:
					_comprobar(pieza == "Cabello" and sprite.texture == null, "La opción sin cabello no reutiliza el peinado anterior")
					continue
				var rect: Rect2 = sprite.global_transform * sprite.get_rect()
				_comprobar(area.get_global_rect().encloses(rect), "Retrato completo sin recortes: %s %d %s" % [genero, indice, pieza])
				limites = rect if limites.size == Vector2.ZERO else limites.merge(rect)
			_comprobar(limites.get_center().distance_to(area.get_global_rect().get_center()) <= 1.0, "Cabeza y cabello se centran juntos")
			_comprobar(is_equal_approx(retrato.scale.x, floorf(retrato.scale.x)), "El retrato usa escala entera sin desenfoque")
			var cabello: Sprite2D = current_scene.get_node("%Cabello")
			if cabello.visible:
				_comprobar(cabello.texture.region == Rect2(cabello.texture.atlas.get_image().get_used_rect()), "El cabello largo conserva todos sus píxeles")
			if indice == rango.x:
				_comprobar(limites.size.y >= 80.0, "El retrato inicial aprovecha la altura disponible")
