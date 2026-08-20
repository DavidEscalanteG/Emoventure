extends Control

# Variables para las imágenes
var img_normal: Texture2D = load("res://assets/assets_escena_payaso/pngtree-clown-icon-simple-style-png-image_15810983.png")
var img_golpeado: Texture2D = load("res://assets/assets_escena_payaso/payaso_golpeado.png")

# Variables de movimiento vertical puro
var altura_escondido: float = 120.0 # Ajusta este valor si necesitas que baje más o menos
var posicion_original: Vector2
var tiempo_bajada_lenta: float = 0.8  # Más lento que el aparecer

signal golpe_recibido # La señal que enviará el payaso


func _ready() -> void:
	# 1. Guardamos la posición exacta en la que colocaste el payaso en el editor
	posicion_original = $Sprite2D.position
	
	# 2. Colocamos el sprite en la posición de "abajo" antes de que se vea
	$Sprite2D.position = posicion_original + Vector2(0, altura_escondido)
	
	# 3. Nos aseguramos de que empiece con la imagen normal
	$Sprite2D.texture = img_normal
	
	# 4. Lo ocultamos completamente
	hide()
	
func reset_estado() -> void:
	$Timer.stop()
	$Sprite2D.position = posicion_original + Vector2(0, altura_escondido)
	$Sprite2D.texture = img_normal
	hide()
	
func aparecer() -> void:
	if visible: return
	$Sprite2D.texture = img_normal # Reset a imagen normal
	show()
	
	var tween: Tween = create_tween()
	# Sube exactamente a la posición donde lo diseñaste, respetando su eje X
	tween.tween_property($Sprite2D, "position", posicion_original, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	$Timer.start()

func golpeado() -> void:
	if visible:
		golpe_recibido.emit() # Avisamos que hubo un punto
		$Timer.stop()
		$Sprite2D.texture = img_golpeado
		# REPRODUCIR SONIDO
		# Cambia el tono ligeramente (entre 0.9 y 1.2) para que no canse el oído
		$AudioStreamPlayer2D.pitch_scale = randf_range(.8, 1.2)
		$AudioStreamPlayer2D.play()
		
		var tween: Tween = create_tween()
		tween.tween_property($Sprite2D, "position", posicion_original + Vector2(0, altura_escondido), tiempo_bajada_lenta)
		
		await tween.finished
		hide()

func _on_timer_timeout() -> void:
	# Si nadie le pegó, baja normal
	var tween: Tween = create_tween()
	tween.tween_property($Sprite2D, "position", posicion_original + Vector2(0, altura_escondido), 0.05)
	await tween.finished
	hide()

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			golpeado()
