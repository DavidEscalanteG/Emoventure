extends Node2D

const dialogo = preload("res://dialogos/escena_1.dialogue")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	DialogueManager.show_dialogue_balloon(dialogo)
	
func set_expr(personaje: String, expresion: String):
	var p = $personajes.get_node(personaje)
	for s in p.get_children():
		s.visible = false
	p.get_node("exp_"+ expresion).visible=true
