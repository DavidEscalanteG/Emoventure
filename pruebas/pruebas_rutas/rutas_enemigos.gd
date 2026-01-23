extends Node2D

const DIALOGO_ESCENA_3 := preload("res://dialogos/escena_3.dialogue")
const SIGUIENTE_ESCENA := "res://escenas/escena_3/escena_3.tscn"

#@onready var personajes := $personajes

func _ready() -> void:
	# Conectamos la señal UNA SOLA VEZ
	#DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	# Pequeña pausa antes de iniciar el diálogo
	await get_tree().create_timer(1.0).timeout
	DialogueManager.show_dialogue_balloon(DIALOGO_ESCENA_3)


# 🔔 Se llama automáticamente cuando termina cualquier diálogo
#func _on_dialogue_ended(resource: Resource) -> void:
#	if resource == DIALOGO_ESCENA_3:
#		get_tree().change_scene_to_file(SIGUIENTE_ESCENA)

# 🎭 Esta función la llama el archivo .dialogue
#func set_expr(personaje: String, expresion: String) -> void:
#	if not personajes.has_node(personaje):
#		push_warning("Personaje no encontrado: %s" % personaje)
#		return

#	var p = personajes.get_node(personaje)

	# 1️⃣ Caso especial: jugador
#	if p.has_method("cambiar_gesto"):
#		p.cambiar_gesto(expresion)
#		return

	# 2️⃣ NPCs: apagar solo expresiones
#	for s in p.get_children():
#		if s.name.begins_with("exp_"):
#			s.visible = false

	# 3️⃣ Activar la expresión correcta (si existe)
#	var nombre_expr := "exp_" + expresion
#	if p.has_node(nombre_expr):
#		p.get_node(nombre_expr).visible = true
#	else:
#		push_warning("Expresión no encontrada: %s en %s" % [expresion, personaje])
