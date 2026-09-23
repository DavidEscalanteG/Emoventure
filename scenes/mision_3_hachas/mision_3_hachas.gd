extends Node2D

const ESCENA_CUESTIONARIO := preload("res://scenes/cuestionarios/EscenaCuestionario.tscn")
const ESCENA_RECOMPENSA := preload("res://scenes/recompensa_mision_3/recompensa_mision_3.tscn")
const TOTAL_NIVELES: int = 10

var _completando: bool = false

func _ready() -> void:
	# Centrar el cuerpo sobre su colisión preserva la posición visual heredada.
	var jugador: CharacterBody2D = $Jugador
	var collision: CollisionShape2D = jugador.get_node("CollisionShape2D")
	var offset := collision.position
	jugador.position += offset
	for child in jugador.get_children():
		if child is Node2D:
			child.position -= offset
	_crear_indicaciones()

func _crear_indicaciones() -> void:
	var numero := 1
	var archivo := scene_file_path.get_file().get_basename()
	if archivo.begins_with("nivel") and not archivo.contains("_"):
		numero = archivo.trim_prefix("nivel").to_int()
	var hud := CanvasLayer.new()
	hud.name = "ProgresoPlataformero"
	var label := Label.new()
	label.position = Vector2(30, 24)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.text = "Misión 3 · Nivel %d/%d\nFlechas o A/D: moverse · Espacio o W: saltar\nLlega a la puerta y evita las trampas." % [numero, TOTAL_NIVELES]
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(label)
	add_child(hud)

func completar_mision() -> void:
	if _completando:
		return
	_completando = true
	$Jugador.set_physics_process(false)
	if GameManager.consumir_modo_rejugabilidad():
		get_tree().change_scene_to_file(GameManager.ESCENA_MAPA_REJUGABILIDAD)
		return
	if not Cuestionarios.validar_mision(3):
		_completando = false
		$Jugador.set_physics_process(true)
		return
	var cuestionario: EscenaCuestionario = ESCENA_CUESTIONARIO.instantiate()
	cuestionario.preguntas = Cuestionarios.obtener_preguntas_para_mision(3)
	cuestionario.dimension = Cuestionarios.obtener_dimension_para_mision(3)
	cuestionario.escena_siguiente = ESCENA_RECOMPENSA
	var tree := get_tree()
	var anterior := tree.current_scene
	# Retirar primero la escena evita que sus peligros sigan actuando este frame.
	tree.root.remove_child(anterior)
	tree.root.add_child(cuestionario)
	tree.current_scene = cuestionario
	anterior.queue_free()
