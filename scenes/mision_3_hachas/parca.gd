extends Node2D

@export_multiline var dialogo_nivel: String = "¡Hola! Este es el diálogo por defecto."
@onready var texto_flotante: RichTextLabel = $RichTextLabel
var _texto_tween: Tween

func _ready() -> void:
	hablar(dialogo_nivel)

func hablar(mensaje_personalizado: String, velocidad_letra: float = 0.05) -> void:
	if _texto_tween != null:
		_texto_tween.kill()
	texto_flotante.text = mensaje_personalizado
	texto_flotante.visible_characters = 0
	var total_letras := texto_flotante.get_total_character_count()
	# El tween pertenece a la parca: se pausa y libera junto con el nivel.
	_texto_tween = create_tween()
	_texto_tween.tween_interval(0.25)
	_texto_tween.tween_property(texto_flotante, "visible_characters", total_letras, total_letras * maxf(velocidad_letra, 0.001))
