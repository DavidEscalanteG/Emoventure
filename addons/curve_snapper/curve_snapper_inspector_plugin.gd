@tool
extends EditorInspectorPlugin

var _editor_plugin: EditorPlugin
var _grid_size: float = 16.0
var _grid_option: OptionButton


func _init(editor_plugin: EditorPlugin) -> void:
	_editor_plugin = editor_plugin


func _can_handle(object: Object) -> bool:
	var selection = _editor_plugin.get_editor_interface().get_selection()
	for node in selection.get_selected_nodes():
		if node is Path2D or node is Area2D:
			return true
	return false


func _parse_begin(object: Object) -> void:
	var container := VBoxContainer.new()

	# === GRID SELECTOR ===
	_grid_option = OptionButton.new()
	_grid_option.add_item("Snap 8px", 8)
	_grid_option.add_item("Snap 16px", 16)
	_grid_option.add_item("Snap 32px", 32)
	_grid_option.selected = 1
	_grid_option.item_selected.connect(_on_grid_selected)

	container.add_child(_grid_option)

	# === BUTTON ===
	var button := Button.new()
	button.text = "Snap To Grid"
	button.tooltip_text = "Snap Path2D curves and Area2D positions."
	button.pressed.connect(_on_snap_pressed)

	container.add_child(button)

	add_custom_control(container)


func _on_grid_selected(index: int) -> void:
	_grid_size = _grid_option.get_item_id(index)


func _on_snap_pressed() -> void:
	var selection = _editor_plugin.get_editor_interface().get_selection()
	var selected_nodes = selection.get_selected_nodes()

	var undo_redo := _editor_plugin.get_undo_redo()
	undo_redo.create_action("Snap To Grid")

	for node in selected_nodes:
		if node is Path2D:
			_snap_path(node, undo_redo)
		elif node is Area2D:
			_snap_area_position(node, undo_redo)

	undo_redo.commit_action()


# =========================
# PATH2D
# =========================

func _snap_path(path: Path2D, undo_redo: EditorUndoRedoManager) -> void:
	var curve := path.curve
	if curve == null:
		return

	for i in curve.point_count:
		var old_position := curve.get_point_position(i)
		var old_in := curve.get_point_in(i)
		var old_out := curve.get_point_out(i)

		var new_position := _snap_vector(old_position)
		var new_in := _snap_vector(old_in)
		var new_out := _snap_vector(old_out)

		if new_position != old_position:
			undo_redo.add_do_method(curve, "set_point_position", i, new_position)
			undo_redo.add_undo_method(curve, "set_point_position", i, old_position)

		if new_in != old_in:
			undo_redo.add_do_method(curve, "set_point_in", i, new_in)
			undo_redo.add_undo_method(curve, "set_point_in", i, old_in)

		if new_out != old_out:
			undo_redo.add_do_method(curve, "set_point_out", i, new_out)
			undo_redo.add_undo_method(curve, "set_point_out", i, old_out)


# =========================
# AREA2D (move whole node)
# =========================

func _snap_area_position(area: Area2D, undo_redo: EditorUndoRedoManager) -> void:
	var old_position := area.position
	var new_position := _snap_vector(old_position)

	if new_position != old_position:
		undo_redo.add_do_property(area, "position", new_position)
		undo_redo.add_undo_property(area, "position", old_position)


# =========================
# SNAP LOGIC
# =========================

func _snap_vector(value: Vector2) -> Vector2:
	return Vector2(_snap_value(value.x), _snap_value(value.y))


func _snap_value(value: float) -> float:
	return round(value / _grid_size) * _grid_size
