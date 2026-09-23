extends Control

# Variables para las imágenes
var img_normal: Texture2D = load("res://assets/assets_escena_payaso/pngtree-clown-icon-simple-style-png-image_15810983.png")
var img_golpeado: Texture2D = load("res://assets/assets_escena_payaso/payaso_golpeado.png")

# Variables de movimiento vertical puro
var altura_escondido: float = 120.0
var posicion_original: Vector2
var tiempo_bajada_lenta: float = 0.8

var fue_golpeado: bool = false # NUEVO: Variable para saber si ya le pegamos en este turno

signal golpe_recibido 

func _ready() -> void:
	posicion_original = $Sprite2D.position
	$Sprite2D.position = posicion_original + Vector2(0, altura_escondido)
	$Sprite2D.texture = img_normal
	hide()
	
func reset_estado() -> void:
	fue_golpeado = false # NUEVO: Reiniciamos la variable al resetear
	$Timer.stop()
	$Sprite2D.position = posicion_original + Vector2(0, altura_escondido)
	$Sprite2D.texture = img_normal
	hide()
	
func aparecer() -> void:
	if visible: return
	fue_golpeado = false # NUEVO: El payaso sale fresco y listo para recibir un golpe
	$Sprite2D.texture = img_normal
	show()
	
	var tween: Tween = create_tween()
	tween.tween_property($Sprite2D, "position", posicion_original, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	$Timer.start()

func golpeado() -> void:
	# NUEVO: Si ya fue golpeado o no está visible, cancelamos todo el código de abajo
	if fue_golpeado or not visible: 
		return
		
	fue_golpeado = true # NUEVO: Registramos que ya recibió el golpe
	
	golpe_recibido.emit()
	$Timer.stop()
	$Sprite2D.texture = img_golpeado
	
	$AudioStreamPlayer2D.pitch_scale = randf_range(.8, 1.2)
	$AudioStreamPlayer2D.play()
	
	var tween: Tween = create_tween()
	tween.tween_property($Sprite2D, "position", posicion_original + Vector2(0, altura_escondido), tiempo_bajada_lenta)
	
	await tween.finished
	hide()

func _on_timer_timeout() -> void:
	var tween: Tween = create_tween()
	tween.tween_property($Sprite2D, "position", posicion_original + Vector2(0, altura_escondido), 0.05)
	await tween.finished
	hide()

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			golpeado()
