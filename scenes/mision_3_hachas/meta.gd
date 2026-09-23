extends Area2D

@export_file("*.tscn") var siguiente_escena: String
@export var finaliza_mision: bool = false

var _cambiando: bool = false

func _on_body_entered(body: Node2D) -> void:
	if _cambiando or not body.has_method("morir"):
		return
	if body.get("_reiniciando") == true:
		return
	_cambiando = true
	# No liberar cuerpos durante una consulta de física.
	_avanzar.call_deferred()

func _avanzar() -> void:
	if finaliza_mision:
		get_parent().completar_mision()
		return
	if siguiente_escena.is_empty():
		push_error("La meta no tiene siguiente escena: " + get_tree().current_scene.scene_file_path)
		_cambiando = false
		return
	var error := get_tree().change_scene_to_file(siguiente_escena)
	if error != OK:
		push_error("No se pudo abrir el siguiente nivel: " + siguiente_escena)
		_cambiando = false
