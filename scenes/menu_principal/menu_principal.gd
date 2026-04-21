extends Control

const InteractiveButtonFX := preload("res://src/ui/effects/interactive_button_fx.gd")


func _ready() -> void:
	InteractiveButtonFX.aplicar_a_botones_en(self)
