extends Control

const MENU_PRINCIPAL_SCENE := "res://scenes/menu_principal/menu_principal.tscn"

@export var titulo_principal: String = "EMOVENTURE"
@export var subtitulo: String = ""

@export var creditos: Array[Dictionary] = [
	{
		"rol": "Fecha de Lanzamiento",
		"personas": ["Noviembre 2026"]
	},
	{
		"rol": "Dirección General",
		"personas": [
			"Dr. Carlos Andrés Miranda Palma",
			"Dra. Lizzie Edmea Narváez Díaz"
		]
	},
	{
		"rol": "Producción",
		"personas": ["VISEE, UADY"]
	},
	{
		"rol": "Diseño del Juego (GDD y Storyboard)",
		"personas": [
			"P/LE. Marcos Abraham Rendón Couoh",
			"P/LE. Sandy Marilyn Monforte Loria"
		]
	},
	{
		"rol": "Diseño de Narrativa y Guion",
		"personas": [
			"P/LE. Marcos Abraham Rendón Couoh",
			"P/LE. Sandy Marilyn Monforte Loria",
			"Br. Buntarou Emiliano Orduño Hara"
		]
	},
	{
		"rol": "Diseño de Interfaz y Experiencia de Usuario",
		"personas": [
			"Dr. Carlos Andrés Miranda Palma",
			"Dra. Lizzie Edmea Narváez Díaz"
		]
	},
	{
		"rol": "Diseño de Niveles",
		"personas": [
			"Br. Buntarou Emiliano Orduño Hara",
			"Br. David Ernesto Escalante García"
		]
	},
	{
		"rol": "Programación",
		"personas": [
			"Br. David Ernesto Escalante García",
			"Br. Buntarou Emiliano Orduño Hara"
		]
	},
	{
		"rol": "Motor de Desarrollo",
		"personas": ["Godot Engine 4.5.1"]
	},
	{
		"rol": "Herramientas y Complementos",
		"personas": [
			"Godot Dialogue Manager",
			"Adobe Premiere Pro 2020",
			"Krita",
			"Gemini"
		]
	},
	{
		"rol": "Arte y Dirección Visual",
		"personas": [
				"Br. José Antonio Mendoza Vázquez",
				"Br. Fausto Cervantes Castañares"
		]
	},
	{
		"rol": "Apoyo en Diseño Gráfico",
		"personas": ["Br. José Antonio Mendoza Vázquez"]
	},
	{
		"rol": "Música y Diseño de Sonido",
		"personas": [
			"Pixabay",
			"Artlist",
			"SoundAudio",
			"Uppbeat",
			"Epidemic Sound"
		]
	},
	{
		"rol": "Instrumento de Evaluación Socioemocional",
		"personas": [
			"Trait Meta-Mood Scale (TMMS-24)",
			"Adaptación de Fernández-Berrocal, P., Extremera, N. y Ramos, N. (2004)",
			"Basado en TMMS-48 de Salovey, Mayer, Goldman, Turvey y Palfai (1995)"
		]
	},
	{
		"rol": "Información Institucional",
		"personas": [
			"Proyecto: VISEE",
			"Instagram: visee.umt",
			"Facebook: VISEE UMT",
			"Soporte técnico: cmiranda@correo.uady.mx"
		]
	},
	{
		"rol": "",
		"personas": [
			"¡Gracias por jugar EmoVenture!",
			"Esperamos que esta experiencia te ayude a reconocer, comprender y fortalecer tus habilidades socioemocionales."
		]
	}
]

@onready var titulo_label: Label = %TituloLabel
@onready var subtitulo_label: Label = %SubtituloLabel
@onready var secciones_container: VBoxContainer = %SeccionesContainer

func _ready() -> void:
	InteractiveButtonFX.aplicar_a_botones_en(self)
	titulo_label.text = titulo_principal
	subtitulo_label.text = subtitulo
	subtitulo_label.visible = not subtitulo.is_empty()
	_construir_creditos()

func _construir_creditos() -> void:
	for child in secciones_container.get_children():
		child.queue_free()

	for seccion in creditos:
		var rol: String = str(seccion.get("rol", ""))
		var personas: Array = seccion.get("personas", [])
		_agregar_seccion(rol, personas)

func _agregar_seccion(rol: String, personas: Array) -> void:
	if not rol.is_empty():
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
		persona_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		secciones_container.add_child(persona_label)

	var separador := HSeparator.new()
	separador.modulate = Color(1, 1, 1, 0.35)
	secciones_container.add_child(separador)

func _on_boton_volver_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file(MENU_PRINCIPAL_SCENE)
