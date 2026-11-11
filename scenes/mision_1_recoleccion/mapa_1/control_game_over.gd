extends Control

@onready var reiniciar_button: Button = $ReiniciarButton

func _ready() -> void:
	visible = false
	reiniciar_button.pressed.connect(_on_reiniciar_pressed)

func mostrar() -> void:
	visible = true

func _on_reiniciar_pressed() -> void:
	AudioManager.play_ui_click()
	
	var escena_actual: Node = get_tree().current_scene
	if escena_actual != null and escena_actual.has_method("cargar_mapa_aleatorio"):
		escena_actual.cargar_mapa_aleatorio()
	else:
		get_tree().reload_current_scene()
