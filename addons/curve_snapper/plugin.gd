@tool
extends EditorPlugin

var _inspector_plugin: EditorInspectorPlugin


func _enter_tree() -> void:
	_inspector_plugin = preload("res://addons/curve_snapper/curve_snapper_inspector_plugin.gd").new(self)
	add_inspector_plugin(_inspector_plugin)


func _exit_tree() -> void:
	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null
