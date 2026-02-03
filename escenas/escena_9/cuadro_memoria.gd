extends TextureButton

@export var imagen_color: Texture2D
@export var imagen_bn: Texture2D

var emocion_asignada: String = ""
var completado := false

signal cuadro_seleccionado(cuadro)
signal cuadro_completado

var hover_tween: Tween
var click_tween: Tween

func _ready():
	if imagen_bn:
		texture_normal = imagen_bn

	scale = Vector2.ONE
	pivot_offset = size / 2
	
	if $Estela.has_node("AnimationPlayer"):
		$Estela/AnimationPlayer.play("onda_idle")

func _on_mouse_entered():
	if completado:
		return
	_iniciar_pulso()

func _on_mouse_exited():
	_detener_pulso()

func _on_pressed():
	if completado:
		return

	_detener_pulso()
	_animar_click()

func _animar_click():
	if click_tween:
		click_tween.kill()

	click_tween = create_tween()
	click_tween.set_trans(Tween.TRANS_SINE)
	click_tween.set_ease(Tween.EASE_IN_OUT)

	click_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.35)
	click_tween.tween_callback(func():
		emit_signal("cuadro_seleccionado", self)
	)

func _iniciar_pulso():
	_detener_pulso()

	hover_tween = create_tween()
	hover_tween.set_loops()
	hover_tween.set_trans(Tween.TRANS_SINE)
	hover_tween.set_ease(Tween.EASE_IN_OUT)

	hover_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.6)
	hover_tween.tween_property(self, "scale", Vector2.ONE, 0.6)

func _detener_pulso():
	if hover_tween:
		hover_tween.kill()

	scale = Vector2.ONE

func marcar_completado(color_estela: Color):
	completado = true
	texture_normal = imagen_color

	$Estela.visible = true
	$Estela.modulate = color_estela
	$Estela.self_modulate.a = 0.9

	# Pequeño pulso neón
	var tween = create_tween()
	tween.tween_property($Estela, "scale", Vector2(1.15, 1.15), 0.25)
	tween.tween_property($Estela, "scale", Vector2.ONE, 0.2)

	scale = Vector2.ONE
	emit_signal("cuadro_completado")

	if has_node("JugadorCinematico"):
		$JugadorCinematico.set_emocion(emocion_asignada)
