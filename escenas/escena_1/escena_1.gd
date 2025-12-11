extends Node2D

const dialogo = preload("res://dialogos/escena_1.dialogue")

func _ready() -> void:
	# Espera un poco y lanza el diálogo
	await get_tree().create_timer(1.0).timeout
	DialogueManager.show_dialogue_balloon(dialogo)
	
# Esta función es la que llama el archivo de diálogo
func set_expr(personaje: String, expresion: String):
	var p = $personajes.get_node(personaje)
	
	# 1. Si es el Jugador, usa su método especial (esto ya lo tienes)
	if p.has_method("cambiar_gesto"):
		p.cambiar_gesto(expresion)
		return

	# 2. Si es un NPC, apaga SOLO las expresiones, no todo lo demás
	for s in p.get_children():
		# BLINDAJE: Solo apaga si el nodo se llama "exp_..."
		if s.name.begins_with("exp_"):
			s.visible = false
			
	# Enciende la correcta
	if p.has_node("exp_" + expresion):
		p.get_node("exp_" + expresion).visible = true
