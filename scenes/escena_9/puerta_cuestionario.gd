extends TextureButton

@export var escena_cuestionario: PackedScene
@export var escena_siguiente: PackedScene

func _on_pressed() -> void:
	if escena_cuestionario == null:
		push_error("No se asignó escena_cuestionario")
		return

	var cuestionario: EscenaCuestionario = escena_cuestionario.instantiate()

	cuestionario.preguntas = [
		"Presto mucha atención a los sentimientos.",
		"Normalmente me preocupo mucho por lo que siento.",
		"Normalmente dedico tiempo a pensar en mis emociones.",
		"Pienso que merece la pena prestar atención a mis emociones.",
		"Dejo que mis sentimientos afecten a mis pensamientos.",
		"Pienso en mi estado de ánimo constantemente.",
		"A menudo pienso en mis sentimientos.",
		"Presto mucha atención a cómo me siento."
	]

	cuestionario.dimension = "atencion"
	cuestionario.escena_siguiente = escena_siguiente

	var root := get_tree().root
	var escena_actual := get_tree().current_scene

	if escena_actual:
		escena_actual.queue_free()

	root.add_child(cuestionario)
	get_tree().current_scene = cuestionario
