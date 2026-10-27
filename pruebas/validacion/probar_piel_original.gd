extends SceneTree

## Comparación de píxeles reales: hoja original frente a la piel predeterminada.
## Requiere renderizado; ejecutar sin --headless.
const HOJAS: String = "res://pruebas/animaciones/hombre_mana_seed/spritesheets/cuerpo/char_a_pONE%d_0bas_humn_v00.png"
const TOLERANCIA: float = 1.1 / 255.0
var fallos: int = 0
var pixeles_comprobados: int = 0


func _initialize() -> void:
	call_deferred("_probar")


func _comprobar(condicion: bool, mensaje: String) -> void:
	if not condicion:
		fallos += 1
		push_error(mensaje)


func _probar() -> void:
	var datos: Node = root.get_node("DatosJugador")
	var vista: SubViewport = SubViewport.new()
	vista.size = Vector2i(1024, 512)
	vista.transparent_bg = true
	vista.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vista)
	var original: Sprite2D = Sprite2D.new()
	original.centered = false
	original.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	vista.add_child(original)
	var actual: Sprite2D = Sprite2D.new()
	actual.position.x = 512.0
	actual.centered = false
	actual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	actual.material = load("res://assets/temas/color_piel.tres")
	actual.self_modulate = datos.apariencia.COLOR_PIEL_INICIAL
	vista.add_child(actual)
	for indice: int in range(1, 4):
		var textura: Texture2D = load(HOJAS % indice)
		original.texture = textura
		actual.texture = textura
		await process_frame
		await RenderingServer.frame_post_draw
		var captura: Image = vista.get_texture().get_image()
		var diferencias: int = 0
		for y: int in range(512):
			for x: int in range(512):
				var esperado: Color = captura.get_pixel(x, y)
				var resultado: Color = captura.get_pixel(x + 512, y)
				if esperado.a > 0.0:
					pixeles_comprobados += 1
				# La comparación del preset original es exacta en el render RGBA8.
				if esperado != resultado:
					diferencias += 1
		_comprobar(diferencias == 0, "La hoja original %d difiere en %d píxeles" % [indice, diferencias])
		print("Hoja %d: %d píxeles diferentes" % [indice, diferencias])
	# Prueba la edición sobre el tono medio y sobre sus sombras reales.
	var muestras: Image = Image.create(5, 1, false, Image.FORMAT_RGBA8)
	muestras.set_pixel(0, 0, Color("885848"))
	muestras.set_pixel(1, 0, Color("d89878"))
	muestras.set_pixel(2, 0, Color("f8d8b8"))
	muestras.set_pixel(3, 0, Color("181818"))
	muestras.set_pixel(4, 0, Color.TRANSPARENT)
	actual.texture = ImageTexture.create_from_image(muestras)
	for elegido: Color in [Color.BLUE, Color.GREEN, Color.WHITE, Color.BLACK, Color.from_hsv(0.42, 0.68, 0.81)]:
		actual.self_modulate = elegido
		await process_frame
		await RenderingServer.frame_post_draw
		var captura: Image = vista.get_texture().get_image()
		_comprobar(_colores_coinciden(captura.get_pixel(513, 0), elegido), "El tono medio debe aplicar el color elegido")
		_comprobar(captura.get_pixel(516, 0).a == 0.0, "Se conserva la transparencia")
		if elegido == Color.WHITE:
			var sombra: Color = captura.get_pixel(512, 0)
			_comprobar(absf(sombra.r - sombra.g) < TOLERANCIA and absf(sombra.g - sombra.b) < TOLERANCIA, "Saturación cero elimina el tinte original")
		if elegido != Color.BLACK:
			_comprobar(captura.get_pixel(515, 0).v < 0.15, "Los contornos siguen oscuros")
	actual.self_modulate = Color(datos.apariencia.COLOR_PIEL_INICIAL, 0.4)
	await process_frame
	await RenderingServer.frame_post_draw
	_comprobar(absf(vista.get_texture().get_image().get_pixel(513, 0).a - 0.4) < TOLERANCIA, "La piel conserva el parpadeo de invulnerabilidad")
	vista.queue_free()
	await process_frame
	print("PIEL ORIGINAL GPU: %d píxeles opacos comprobados, %d fallos" % [pixeles_comprobados, fallos])
	quit(0 if fallos == 0 else 1)


func _colores_coinciden(esperado: Color, actual: Color) -> bool:
	return absf(esperado.r - actual.r) <= TOLERANCIA and absf(esperado.g - actual.g) <= TOLERANCIA and absf(esperado.b - actual.b) <= TOLERANCIA and absf(esperado.a - actual.a) <= TOLERANCIA
