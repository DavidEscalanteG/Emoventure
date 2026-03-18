extends TextureButton

func _on_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/menu_guardados/menu_guardados.tscn")
