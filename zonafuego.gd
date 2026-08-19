extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Si la colisión está activada (segundo 2.5) y toca al jugador, muere
	if body.has_method("morir"):
		body.morir()
