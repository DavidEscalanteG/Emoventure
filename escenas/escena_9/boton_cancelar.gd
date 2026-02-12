extends Button

@onready var selector: Node = find_parent("SelectorEmocion")

func _on_pressed() -> void:
	if selector:
		Logs.log_debug("[DEBUG] Botón cancelar presionado")
		selector.cancelar_seleccion()
