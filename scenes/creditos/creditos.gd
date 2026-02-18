extends Control

const MENU_PRINCIPAL_SCENE := "res://scenes/menu_principal/menu_principal.tscn"

@export var titulo_principal: String = "Créditos"
@export var subtitulo: String = "Gracias por jugar Emoventure"
@export var creditos: Array[Dictionary] = [
	{
		"rol": "Desarrollo",
		"personas": ["David Ernesto Escalante García
		Emiliano Orduño"]
	},
	{
		"rol": "Arte",
		"personas": ["Evan"]
	},
	{
		"rol": "QA / Testing",
		"personas": ["David Ernesto Escalante García"]
	}
]

@onready var titulo_label: Label = %TituloLabel
@onready var subtitulo_label: Label = %SubtituloLabel
@onready var secciones_container: VBoxContainer = %SeccionesContainer

func _ready() -> void:
	titulo_label.text = titulo_principal
	subtitulo_label.text = subtitulo
	_construir_creditos()

func _construir_creditos() -> void:
	for child in secciones_container.get_children():
		child.queue_free()

	for seccion in creditos:
		var rol: String = str(seccion.get("rol", "Rol sin nombre"))
		var personas: Array = seccion.get("personas", [])
		_agregar_seccion(rol, personas)

func _agregar_seccion(rol: String, personas: Array) -> void:
	var rol_label := Label.new()
	rol_label.text = rol
	rol_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rol_label.add_theme_font_size_override("font_size", 44)
	secciones_container.add_child(rol_label)

	for persona in personas:
		var persona_label := Label.new()
		persona_label.text = str(persona)
		persona_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		persona_label.add_theme_font_size_override("font_size", 30)
		secciones_container.add_child(persona_label)

	var separador := HSeparator.new()
	separador.modulate = Color(1, 1, 1, 0.35)
	secciones_container.add_child(separador)

func _on_boton_volver_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file(MENU_PRINCIPAL_SCENE)
