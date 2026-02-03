extends CharacterBody2D

@onready var apariencia: Node = $PlayerAppearance

func _ready() -> void:
	apariencia.aplicar_apariencia_desde_global()
	apariencia.set_direction("down")
	apariencia.set_estado_movimiento("idle")
	
	set_emocion("ninguna")


func set_emocion(nombre: String):
	var appearance := $PlayerAppearance

	appearance.set_estado_movimiento("idle")
	appearance.set_direction("down")

	# SOLO cuerpo por ahora
	var anim := "emocion_" + nombre

	if appearance.cuerpo.sprite_frames \
	and appearance.cuerpo.sprite_frames.has_animation(anim):
		appearance.cuerpo.play(anim)

func confirmar_emocion_visual():
	scale = Vector2(1, 1)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	tween.tween_property(self, "scale", Vector2.ONE, 0.15)
