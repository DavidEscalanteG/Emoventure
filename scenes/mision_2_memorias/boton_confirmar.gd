extends Button

@onready var selector: Node = find_parent("SelectorEmocion")

func _on_pressed() -> void:
	disabled = true
	selector.confirmar_emocion()
