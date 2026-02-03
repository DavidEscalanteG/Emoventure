extends Button

@onready var selector := find_parent("SelectorEmocion")

func _on_pressed():
	disabled = true
	selector.confirmar_emocion()
