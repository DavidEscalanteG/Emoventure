extends Node

const PAUSE_OVERLAY_SCENE := preload("res://src/ui/pause_overlay.tscn")
const PAUSABLE_PREFIXES: Array[String] = [
	"res://scenes/intro_",
	"res://scenes/mision_",
	"res://scenes/transicion_",
	"res://scenes/recompensa_",
	"res://scenes/rejugabilidad/",
	"res://scenes/cuestionarios/",
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().node_added.connect(_on_node_added)
	call_deferred("_inyectar_en_escena_actual")


func _on_node_added(node: Node) -> void:
	if node == get_tree().current_scene:
		call_deferred("_inyectar_en_escena_actual")


func _inyectar_en_escena_actual() -> void:
	var escena_actual := get_tree().current_scene
	if escena_actual == null:
		return
	if not _debe_tener_pausa(escena_actual.scene_file_path):
		return
	if escena_actual.has_node("PauseOverlay"):
		return
	_crear_overlay(escena_actual)


func _crear_overlay(escena_actual: Node) -> Node:
	var overlay := PAUSE_OVERLAY_SCENE.instantiate()
	overlay.name = "PauseOverlay"
	escena_actual.add_child(overlay)
	return overlay


func _debe_tener_pausa(scene_path: String) -> bool:
	if scene_path.is_empty():
		return false
	for prefix: String in PAUSABLE_PREFIXES:
		if scene_path.begins_with(prefix):
			return true
	return false
