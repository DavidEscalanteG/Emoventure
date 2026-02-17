extends Control

@export var siguiente_escena: String = "res://scenes/final/resultado_final.tscn"
@export var siguiente_escena_legacy: String = ""

func _on_boton_continuar_pressed() -> void:
	AudioManager.play_ui_click()
	var destino := siguiente_escena if not siguiente_escena.is_empty() else siguiente_escena_legacy
	if destino.is_empty():
		push_warning("No se configuró destino para la recompensa de misión 3")
		return
	get_tree().change_scene_to_file(destino)
