extends CharacterBody2D

@export var iniciar_con_emocion_neutra: bool = false

@onready var apariencia: Node = $PlayerAppearance

@export var forzar_indice_cabello: int = -1

func _ready() -> void:
	if forzar_indice_cabello >= 0:
		apariencia._aplicar_spriteframes(
			apariencia.cabello,
			apariencia.coleccion_cabellos,
			forzar_indice_cabello
		)
		apariencia._actualizar_animacion()
	else:
		apariencia.aplicar_apariencia_desde_global()

	apariencia.set_direction("down")
	apariencia.set_estado_movimiento("idle")
	
	if iniciar_con_emocion_neutra:
		set_emocion("ninguna")
	else:
		_reproducir_idle_normal()


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

func _reproducir_idle_normal() -> void:
	var appearance := $PlayerAppearance
	var anim := "idle_down"

	if appearance.cuerpo.sprite_frames \
	and appearance.cuerpo.sprite_frames.has_animation(anim):
		appearance.cuerpo.play(anim)
