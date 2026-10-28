extends Node

func _ready() -> void:
	# Verificamos si estamos corriendo en la Web y en un dispositivo móvil
	if OS.has_feature("web") and OS.has_feature("mobile"):
		# Escuchamos cuando se agregue cualquier nodo nuevo a la escena
		get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	# Si el nodo que apareció es un LineEdit, le inyectamos el comportamiento móvil
	if node is LineEdit:
		if not node.focus_entered.is_connected(_manejar_input_movil.bind(node)):
			node.focus_entered.connect(_manejar_input_movil.bind(node))

func _manejar_input_movil(line_edit: LineEdit) -> void:
	# Quitamos el foco para que el teclado virtual bugeado de Godot no se abra
	line_edit.release_focus()
	
	# Abrimos el cuadro de diálogo nativo del celular (Prompt del navegador)
	var js_code = "prompt('Ingresa el texto:', '%s');" % line_edit.text
	var resultado = JavaScriptBridge.eval(js_code)
	
	# Si el usuario escribió algo y aceptó, actualizamos el texto
	if resultado != null:
		line_edit.text = str(resultado)
		# Emitimos la señal de texto cambiado o enviado por si tus scripts la escuchan
		line_edit.text_changed.emit(line_edit.text)
