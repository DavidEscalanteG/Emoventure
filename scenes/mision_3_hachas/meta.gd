extends Area2D

# Esto te permite arrastrar la escena del siguiente nivel desde el editor
@export_file("*.tscn") var siguiente_escena: String

func _on_body_entered(body):
	if body.name == "Jugador":
		get_tree().change_scene_to_file(siguiente_escena)
