extends Node

const PAUSE_OVERLAY_SCENE := preload("res://src/ui/pause_overlay.tscn")


func _ready() -> void:
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
	var overlay := PAUSE_OVERLAY_SCENE.instantiate()
	overlay.name = "PauseOverlay"
	escena_actual.add_child(overlay)


func _debe_tener_pausa(scene_path: String) -> bool:
	if scene_path.is_empty():
		return false
	return scene_path.begins_with("res://scenes/intro_") \
		or scene_path.begins_with("res://scenes/mision_")
