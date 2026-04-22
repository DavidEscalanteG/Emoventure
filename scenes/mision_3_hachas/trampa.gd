extends Area2D

func _on_body_entered(body):
	# Verificamos si lo que entró es el jugador
	if body.name == "Jugador":
		# Esta función reinicia automáticamente el nivel donde estés
		get_tree().reload_current_scene()
