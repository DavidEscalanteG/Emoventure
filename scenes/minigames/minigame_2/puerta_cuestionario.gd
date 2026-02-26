extends TextureButton

@export var escena_cuestionario: PackedScene
@export var escena_siguiente: PackedScene
@export var numero_mision_cuestionario: int = 2

func _on_pressed() -> void:
	AudioManager.play_ui_click()
	if GameManager.consumir_modo_rejugabilidad():
		get_tree().change_scene_to_file(GameManager.ESCENA_MAPA_REJUGABILIDAD)
		return
		
	if escena_cuestionario == null:
		push_error("No se asignó escena_cuestionario")
		return

	if not Cuestionarios.validar_mision(numero_mision_cuestionario):
		return

	var cuestionario: EscenaCuestionario = escena_cuestionario.instantiate()
	var dimension: String = Cuestionarios.obtener_dimension_para_mision(numero_mision_cuestionario)
	
	cuestionario.preguntas = Cuestionarios.obtener_preguntas_para_mision(numero_mision_cuestionario)
	cuestionario.dimension = dimension
	cuestionario.escena_siguiente = escena_siguiente

	var root := get_tree().root
	var escena_actual := get_tree().current_scene

	if escena_actual:
		escena_actual.queue_free()

	root.add_child(cuestionario)
	get_tree().current_scene = cuestionario
