extends Control

@export var siguiente_escena: String = "res://scenes/menu_principal/menu_principal.tscn"

func _on_boton_continuar_pressed() -> void:
	get_tree().change_scene_to_file(siguiente_escena)