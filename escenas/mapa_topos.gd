extends Node2D

var cursor_normal = load("res://assets/martillo.png")
var cursor_golpe = load("res://assets/martillo_pegando.png")
var puntos = 0

func _ready():
	randomize()
	# Aquí es donde conectamos a todos los hijos que sean payasos
	for payaso in get_children():
		if payaso.has_signal("golpe_recibido"):
			payaso.connect("golpe_recibido", _al_sumar_punto)
	# Establecemos el cursor inicial
	Input.set_custom_mouse_cursor(cursor_normal)

func _input(event):
	# Si presionas el clic izquierdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Cambia a la imagen de golpe
			Input.set_custom_mouse_cursor(cursor_golpe)
		else:
			# Cuando sueltas el clic, vuelve a la normal
			Input.set_custom_mouse_cursor(cursor_normal)

var dificultad = 1.0 # Cantidad base de payasos
var velocidad_minima = 0.4 # El tope de rapidez del timer

func _al_sumar_punto():
	puntos += 1
	# Ahora sí, Main puede encontrar al Label
	$CanvasLayer/MarcadorPuntos.text = "Puntos: " + str(puntos)
	
func _on_spawn_timer_timeout():
	var hijos = get_children()
	
	# 1. Calculamos cuántos payasos saldrán (por ejemplo, 1 cada 5 puntos)
	# O simplemente puedes poner un número fijo para probar:
	var cantidad_a_salir = int(dificultad) 
	
	for i in range(cantidad_a_salir):
		var payaso_aleatorio = hijos[randi() % hijos.size()]
		if payaso_aleatorio.has_method("aparecer"):
			payaso_aleatorio.aparecer()

	# 2. Aceleramos el Timer poco a poco
	if $SpawnTimer.wait_time > velocidad_minima:
		$SpawnTimer.wait_time -= 0.05 # Se vuelve 0.05s más rápido cada vez
	
	# 3. Aumentamos la dificultad (más payasos a la vez con el tiempo)
	if dificultad < 5: # Máximo 5 payasos simultáneos
		dificultad += 0.1



func _on_timer_juego_timeout():
	# Detener el juego
	$SpawnTimer.stop()
	print("Fin del juego")
	# Aquí puedes mostrar un mensaje de Game Over
