extends Node2D


@onready var texto_flotante = $RichTextLabel

func _ready():
	# Esperamos un cuarto de segundo para que cargue bien la pantalla
	await get_tree().create_timer(0.25).timeout
	
	# Llamamos a la función con el mensaje personalizado que quieras
	hablar("Parece fácil pero no lo lograrás")

func hablar(mensaje_personalizado: String, velocidad_letra: float = 0.1):
	# Asignamos el texto (aquí puedes meter comandos de personalización)
	texto_flotante.text = mensaje_personalizado
	
	# Empezamos con 0 letras visibles
	texto_flotante.visible_characters = 0
	
	# Obtenemos el total de letras del mensaje
	var total_letras = texto_flotante.get_total_character_count()
	
	# Ciclo para ir mostrando una por una
	while texto_flotante.visible_characters < total_letras:
		texto_flotante.visible_characters += 1
		# Esperamos unos milisegundos antes de la siguiente letra
		await get_tree().create_timer(velocidad_letra).timeout
	
