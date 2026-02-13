extends Control

# Variables para las imágenes
var img_normal: Texture2D = load("res://assets/assets_escena_payaso/pngtree-clown-icon-simple-style-png-image_15810983.png")
var img_golpeado: Texture2D = load("res://assets/assets_escena_payaso/payaso_golpeado.png")

# Variables de movimiento
var pos_escondido: Vector2 = Vector2(0, 50)
var pos_afuera: Vector2 = Vector2(0, 0)
var tiempo_bajada_lenta: float = 0.8  # Más lento que el aparecer

signal golpe_recibido # La señal que enviará el payaso


func _ready() -> void:
	# 1. Colocamos el sprite en la posición de "abajo" antes de que se vea
	$Sprite2D.position = pos_escondido
	
	# 2. Nos aseguramos de que empiece con la imagen normal
	$Sprite2D.texture = img_normal
	
	# 3. Lo ocultamos completamente
	hide()
	
func aparecer() -> void:
	if visible: return
	$Sprite2D.texture = img_normal # Reset a imagen normal
	show()
	
	var tween: Tween = create_tween()
	tween.tween_property($Sprite2D, "position", pos_afuera, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	$Timer.start()

func golpeado() -> void:
	if visible:
		emit_signal("golpe_recibido") # Avisamos que hubo un punto
		$Timer.stop()
		$Sprite2D.texture = img_golpeado
		# REPRODUCIR SONIDO
		# Cambia el tono ligeramente (entre 0.9 y 1.2) para que no canse el oído
		$AudioStreamPlayer2D.pitch_scale = randf_range(.8, 1.2)
		$AudioStreamPlayer2D.play()
		
		var tween: Tween = create_tween()
		tween.tween_property($Sprite2D, "position", pos_escondido, tiempo_bajada_lenta)
		
		await tween.finished
		hide()

func _on_timer_timeout() -> void:
	# Si nadie le pegó, baja normal
	var tween: Tween = create_tween()
	tween.tween_property($Sprite2D, "position", pos_escondido, 0.05)
	await tween.finished
	hide()

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			golpeado()
			
