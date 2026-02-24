@tool
extends EditorInspectorPlugin

const SNAP_SIZE := 16.0

var _editor_plugin: EditorPlugin


func _init(editor_plugin: EditorPlugin) -> void:
	_editor_plugin = editor_plugin


func _can_handle(object: Object) -> bool:
	return object is Path2D


func _parse_begin(object: Object) -> void:
	var path := object as Path2D
	if path == null:
		return

	var button := Button.new()
	button.text = "Snap Curve to 16 Grid"
	button.tooltip_text = "Round all curve point vectors (position, in, out) to the nearest 16px grid."
	button.pressed.connect(_on_snap_pressed.bind(path))
	add_custom_control(button)


func _on_snap_pressed(path: Path2D) -> void:
	if not is_instance_valid(path):
		return

	var curve := path.curve
	if curve == null:
		return

	var point_count := curve.point_count
	if point_count == 0:
		return

	var changes: Array[Dictionary] = []
	for i in point_count:
		var old_position := curve.get_point_position(i)
		var old_in := curve.get_point_in(i)
		var old_out := curve.get_point_out(i)

		var new_position := _snap_vector(old_position)
		var new_in := _snap_vector(old_in)
		var new_out := _snap_vector(old_out)

		if new_position != old_position or new_in != old_in or new_out != old_out:
			changes.append({
				"index": i,
				"old_position": old_position,
				"new_position": new_position,
				"old_in": old_in,
				"new_in": new_in,
				"old_out": old_out,
				"new_out": new_out,
			})

	if changes.is_empty():
		return

	var undo_redo := _editor_plugin.get_undo_redo()
	undo_redo.create_action("Snap Curve to 16 Grid")

	for change in changes:
		var index: int = change["index"]
		undo_redo.add_do_method(curve, "set_point_position", index, change["new_position"])
		undo_redo.add_undo_method(curve, "set_point_position", index, change["old_position"])
		undo_redo.add_do_method(curve, "set_point_in", index, change["new_in"])
		undo_redo.add_undo_method(curve, "set_point_in", index, change["old_in"])
		undo_redo.add_do_method(curve, "set_point_out", index, change["new_out"])
		undo_redo.add_undo_method(curve, "set_point_out", index, change["old_out"])

	undo_redo.commit_action()


func _snap_vector(value: Vector2) -> Vector2:
	return Vector2(_snap_value(value.x), _snap_value(value.y))


func _snap_value(value: float) -> float:
	return round(value / SNAP_SIZE) * SNAP_SIZE
