extends TextureButton
var AudioManager: Object = Engine.get_singleton("AudioManager") if Engine.has_singleton("AudioManager") else ((Engine.get_main_loop().root.get_node_or_null("AudioManager")) if Engine.get_main_loop() is SceneTree else null)


func _on_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/configuracion/configuracion.tscn")