extends SceneTree

## Prueba real del shader en GPU. Ejecutar sin --headless, con gl_compatibility.
func _initialize() -> void:
	call_deferred("_probar")


func _probar() -> void:
	var vista: SubViewport = SubViewport.new()
	vista.size = Vector2i(32, 32)
	vista.transparent_bg = true
	vista.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vista)
	var imagen: Image = Image.create(2, 2, false, Image.FORMAT_RGBA8)
	imagen.set_pixel(0, 0, Color(0.9, 0.3, 0.1, 1.0))
	imagen.set_pixel(1, 0, Color(0.3, 0.8, 0.4, 1.0))
	imagen.set_pixel(0, 1, Color(0.1, 0.1, 0.1, 1.0))
	imagen.set_pixel(1, 1, Color.TRANSPARENT)
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(imagen)
	sprite.centered = false
	sprite.scale = Vector2(16, 16)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.material = load("res://assets/temas/color_personaje.tres")
	vista.add_child(sprite)
	var fallos: int = 0
	for color: Color in [Color.WHITE, Color.RED, Color.GREEN, Color.BLUE, Color.from_hsv(0.42, 0.68, 0.81)]:
		sprite.self_modulate = color
		await process_frame
		await RenderingServer.frame_post_draw
		var captura: Image = vista.get_texture().get_image()
		for caso: Dictionary in [
			{"punto": Vector2i(8, 8), "luz": 0.9},
			{"punto": Vector2i(24, 8), "luz": 0.8},
			{"punto": Vector2i(8, 24), "luz": 0.1}
		]:
			var pixel: Color = captura.get_pixelv(caso.punto)
			var esperado: Color = Color(color.r * caso.luz, color.g * caso.luz, color.b * caso.luz, 1.0)
			if absf(pixel.r - esperado.r) > 0.015 or absf(pixel.g - esperado.g) > 0.015 or absf(pixel.b - esperado.b) > 0.015:
				push_error("Color incorrecto en GPU: %s, esperado %s" % [pixel, esperado])
				fallos += 1
		if captura.get_pixel(24, 24).a > 0.01:
			push_error("El shader debe conservar la transparencia")
			fallos += 1
	vista.queue_free()
	await process_frame
	print("COLOR PERSONAJE GPU: 20 comprobaciones, %d fallos" % fallos)
	quit(0 if fallos == 0 else 1)
