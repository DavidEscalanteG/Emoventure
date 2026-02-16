extends Button
var Logs: Object = Engine.get_singleton("Logs") if Engine.has_singleton("Logs") else ((Engine.get_main_loop().root.get_node_or_null("Logs")) if Engine.get_main_loop() is SceneTree else null)


@onready var selector: Node = find_parent("SelectorEmocion")

func _on_pressed() -> void:
	if selector:
		Logs.log_debug("[DEBUG] Botón cancelar presionado")
		selector.cancelar_seleccion()
