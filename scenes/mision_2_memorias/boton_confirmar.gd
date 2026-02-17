extends Button

@onready var selector: Node = find_parent("SelectorEmocion")

func _on_pressed() -> void:
	AudioManager.play_ui_click()
	disabled = true
	selector.confirmar_emocion()
