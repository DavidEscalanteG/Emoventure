extends Node2D

var cursor_normal = load("res://assets/martillo.png")
var cursor_golpe = load("res://assets/martillo_pegando.png")
var puntos = 0
var topos_jugables = []

func _ready():
	randomize()
	# Cacheamos solo los nodos jugables una vez (los que aparecen y/o emiten golpe)
	for topo in get_children():
		if topo.has_method("aparecer") or topo.has_signal("golpe_recibido"):
			topos_jugables.append(topo)

	# Conectamos señales únicamente para la lista cacheada
	for topo in topos_jugables:
		if topo.has_signal("golpe_recibido"):
			topo.connect("golpe_recibido", _al_sumar_punto)
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
	if topos_jugables.is_empty():
		return

	# Evitamos repetir el mismo topo en un mismo ciclo de spawn
	var disponibles = topos_jugables.filter(func(topo): return topo.has_method("aparecer"))
	if disponibles.is_empty():
		return
	
	# 1. Calculamos cuántos payasos saldrán (por ejemplo, 1 cada 5 puntos)
	# O simplemente puedes poner un número fijo para probar:
	var cantidad_a_salir = min(int(dificultad), disponibles.size())
	
	for i in range(cantidad_a_salir):
		var indice_aleatorio = randi() % disponibles.size()
		var payaso_aleatorio = disponibles[indice_aleatorio]
		payaso_aleatorio.aparecer()
		disponibles.remove_at(indice_aleatorio)

	# 2. Aceleramos el Timer poco a poco
	if $SpawnTimer.wait_time > velocidad_minima:
		$SpawnTimer.wait_time -= 0.05 # Se vuelve 0.05s más rápido cada vez
	
	# 3. Aumentamos la dificultad (más payasos a la vez con el tiempo)
	if dificultad < 5: # Máximo 5 payasos simultáneos
		dificultad += 0.1



func _on_timer_juego_timeout():
	# Detener el juego
	$SpawnTimer.stop()
	Logs.log_debug("Fin del juego")
	# Aquí puedes mostrar un mensaje de Game Over
