extends Control

@onready var icons = {
	"alegria": $HBoxContainer/AlegriaIcon,
	"tristeza": $HBoxContainer/TristezaIcon,
	"enojo": $HBoxContainer/EnojoIcon,
	"desagrado": $HBoxContainer/DesagradoIcon,
	"miedo": $HBoxContainer/MiedoIcon
}

func _ready():
	Global.emotions_ui = self
	# Al inicio todas apagadas
	for icon in icons.values():
		_set_inactive(icon)

func unlock_emotion(emotion_name: String):
	if icons.has(emotion_name):
		_set_active(icons[emotion_name])

func _set_active(icon):
	icon.modulate = Color(1, 1, 1, 1)
	icon.scale = Vector2(1.3, 1.3)

	var tween = create_tween()
	tween.tween_property(icon, "scale", Vector2.ONE, 0.2)\
		 .set_trans(Tween.TRANS_BACK)\
		 .set_ease(Tween.EASE_OUT)

func _set_inactive(icon: TextureRect):
	icon.modulate = Color(0.35, 0.35, 0.35, 0.9)
