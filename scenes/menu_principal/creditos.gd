extends Button

const CREDITOS_SCENE := "res://scenes/creditos/creditos.tscn"

func _on_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file(CREDITOS_SCENE)
