extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si la cosa que chocó tiene la función de morir
	if body.has_method("morir"):
		body.morir()
