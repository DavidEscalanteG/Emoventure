extends Button


func _on_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().quit()
