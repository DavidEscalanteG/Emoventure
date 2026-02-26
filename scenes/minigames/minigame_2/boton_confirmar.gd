extends Button

@onready var selector: Node = find_parent("SelectorEmocion")

func _on_pressed() -> void:
	AudioManager.play_ui_click()
	var confirmado: bool = selector.confirmar_emocion()
	if confirmado:
		disabled = true
