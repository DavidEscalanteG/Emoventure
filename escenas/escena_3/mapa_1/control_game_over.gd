extends Control

@onready var reiniciar_button: Button = $ReiniciarButton

func _ready():
	visible = false
	reiniciar_button.pressed.connect(_on_reiniciar_pressed)

func mostrar():
	visible = true

func _on_reiniciar_pressed():
	get_tree().reload_current_scene()
