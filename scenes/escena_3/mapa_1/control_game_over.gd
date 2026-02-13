extends Control

@onready var reiniciar_button: Button = $ReiniciarButton

func _ready() -> void:
	visible = false
	reiniciar_button.pressed.connect(_on_reiniciar_pressed)

func mostrar() -> void:
	visible = true

func _on_reiniciar_pressed() -> void:
	get_tree().reload_current_scene()
