extends Control
var DatosJugador: Object = Engine.get_singleton("DatosJugador") if Engine.has_singleton("DatosJugador") else null


@onready var icons: Dictionary[String, TextureRect] = {
	"alegria": $HBoxContainer/AlegriaIcon,
	"tristeza": $HBoxContainer/TristezaIcon,
	"enojo": $HBoxContainer/EnojoIcon,
	"desagrado": $HBoxContainer/DesagradoIcon,
	"miedo": $HBoxContainer/MiedoIcon
}

func _ready() -> void:
	DatosJugador.emotions_ui = self
	# Al inicio todas apagadas
	for icon in icons.values():
		_set_inactive(icon)

func unlock_emotion(emotion_name: String) -> void:
	if icons.has(emotion_name):
		_set_active(icons[emotion_name])

func _set_active(icon: TextureRect) -> void:
	icon.modulate = Color(1, 1, 1, 1)
	icon.scale = Vector2(1.3, 1.3)

	var tween: Tween = create_tween()
	tween.tween_property(icon, "scale", Vector2.ONE, 0.2)\
		 .set_trans(Tween.TRANS_BACK)\
		 .set_ease(Tween.EASE_OUT)

func _set_inactive(icon: TextureRect) -> void:
	icon.modulate = Color(0.35, 0.35, 0.35, 0.9)
