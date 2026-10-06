extends SceneTree

var failures: int = 0
var checked: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_scan("res://")
	print("VALIDACION: %d recursos, %d fallos" % [checked, failures])
	quit(1 if failures else 0)

func _scan(path: String) -> void:
	for directory in DirAccess.get_directories_at(path):
		if directory.begins_with(".") or directory == "addons":
			continue
		_scan(path.path_join(directory))
	for file in DirAccess.get_files_at(path):
		if file.get_extension() not in ["gd", "tscn", "tres"]:
			continue
		var resource_path := path.path_join(file)
		var resource := load(resource_path)
		checked += 1
		if resource == null:
			print("FALLO AL CARGAR: ", resource_path)
			failures += 1
		elif resource is PackedScene:
			var instance := (resource as PackedScene).instantiate()
			if instance == null:
				print("FALLO AL INSTANCIAR: ", resource_path)
				failures += 1
			else:
				instance.free()
