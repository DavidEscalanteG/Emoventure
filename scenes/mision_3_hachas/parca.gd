extends Node2D

@onready var texto_flotante = $RichTextLabel

# Creamos una variable exportada para el diálogo
@export_multiline var dialogo_nivel: String = "¡Hola! Este es el diálogo por defecto."

func _ready():
	await get_tree().create_timer(0.25).timeout
	# En lugar de texto fijo, usamos la variable exportada
	hablar(dialogo_nivel)

func hablar(mensaje_personalizado: String, velocidad_letra: float = 0.05):
	texto_flotante.text = mensaje_personalizado
	texto_flotante.visible_characters = 0
	var total_letras = texto_flotante.get_total_character_count()
	
	while texto_flotante.visible_characters < total_letras:
		texto_flotante.visible_characters += 1
		await get_tree().create_timer(velocidad_letra).timeout
