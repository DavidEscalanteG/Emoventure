class_name GameFlowManager
extends Node

## Orquesta el flujo global de escenas para desacoplar UI y gameplay.

const MAIN_MENU_SCENE: String = "res://scenes/main_menu/menu_principal/menu_principal.tscn"
const RESULTS_SCENE: String = "res://scenes/results/final/resultado_final.tscn"
const REPLAY_MAP_SCENE: String = "res://scenes/map/rejugabilidad/mapa_rejugabilidad.tscn"


func go_to_main_menu() -> void:
	_change_scene(MAIN_MENU_SCENE)


func go_to_results() -> void:
	_change_scene(RESULTS_SCENE)


func go_to_replay_map() -> void:
	_change_scene(REPLAY_MAP_SCENE)


func go_to_scene(scene_path: String) -> void:
	_change_scene(scene_path)


func _change_scene(scene_path: String) -> void:
	if scene_path.is_empty():
		Logs.log_error("GameFlowManager", "Ruta de escena vacía")
		return
	var error_code: Error = get_tree().change_scene_to_file(scene_path)
	if error_code != OK:
		Logs.log_error("GameFlowManager", "No se pudo cargar %s (error %d)" % [scene_path, error_code])
