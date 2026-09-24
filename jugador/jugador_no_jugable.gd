extends CharacterBody2D

# --- Camuflaje para evitar que el nivel crashee ---
var nivel_terminado: bool = false
var vidas_actuales: int = 3 

# --- Variables originales de apariencia ---
@export var iniciar_con_emocion_neutra: bool = false
@export var forzar_indice_cabello: int = -1

@onready var apariencia: Node = $PlayerAppearance

func _ready() -> void:
	# Solo dejamos el registro del diálogo para las cinemáticas
	DialogueActors.registro_registrar_actor("jugador", self)

	refrescar_preview()

	if iniciar_con_emocion_neutra:
		set_emocion("ninguna")
	else:
		_reproducir_idle_normal()

func refrescar_preview() -> void:
	if forzar_indice_cabello >= 0:
		apariencia.aplicar_spriteframes_por_indice(
			apariencia.cabello,
			apariencia.coleccion_cabellos,
			forzar_indice_cabello
		)
		apariencia.actualizar_animacion_visual()
	else:
		apariencia.aplicar_apariencia_desde_global()

	apariencia.establecer_direccion("down")
	apariencia.establecer_estado_movimiento("idle")

func set_emocion(nombre: String) -> void:
	var appearance := $PlayerAppearance

	appearance.establecer_estado_movimiento("idle")
	appearance.establecer_direccion("down")

	var anim := "emocion_" + nombre

	if appearance.cuerpo.sprite_frames \
	and appearance.cuerpo.sprite_frames.has_animation(anim):
		appearance.cuerpo.play(anim)

func confirmar_emocion_visual() -> void:
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

# --- Funciones Escudo (Camuflaje) ---
func permitir_movimiento() -> void:
	pass

func bloquear_movimiento() -> void:
	pass

func desbloquear_movimiento() -> void:
	pass

func terminar_emocion() -> void:
	pass
