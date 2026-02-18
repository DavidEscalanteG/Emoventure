class_name CuadroMemoria
extends TextureButton

@export var imagen_color: Texture2D
@export var imagen_bn: Texture2D
@export var id_cuadro: int = -1

var emocion_asignada: String = ""
var completado: bool = false

signal cuadro_seleccionado(cuadro: CuadroMemoria)
signal cuadro_completado(cuadro: CuadroMemoria, emocion: String)

var hover_tween: Tween = null
var click_tween: Tween = null
var estela_tween: Tween = null

@onready var estela: TextureRect = $Estela
@onready var emoji_animado: AnimatedSprite2D = $EmojiAnimado


func _ready() -> void:
	if imagen_bn != null:
		texture_normal = imagen_bn

	scale = Vector2.ONE
	pivot_offset = size / 2.0
	_update_layout_overlays()
	resized.connect(_on_resized)
	_configurar_estela_inicial()


func _on_mouse_entered() -> void:
	if completado:
		return
	_iniciar_pulso()


func _on_mouse_exited() -> void:
	_detener_pulso()


func _on_pressed() -> void:
	AudioManager.play_ui_click()
	if completado:
		return

	_detener_pulso()
	_animar_click()


func _animar_click() -> void:
	if click_tween != null:
		click_tween.kill()

	click_tween = create_tween()
	click_tween.set_trans(Tween.TRANS_SINE)
	click_tween.set_ease(Tween.EASE_IN_OUT)
	click_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.35)
	click_tween.tween_callback(func() -> void:
		cuadro_seleccionado.emit(self)
	)


func _iniciar_pulso() -> void:
	_detener_pulso()

	hover_tween = create_tween()
	hover_tween.set_loops()
	hover_tween.set_trans(Tween.TRANS_SINE)
	hover_tween.set_ease(Tween.EASE_IN_OUT)
	hover_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.6)
	hover_tween.tween_property(self, "scale", Vector2.ONE, 0.6)


func _detener_pulso() -> void:
	if hover_tween != null:
		hover_tween.kill()

	scale = Vector2.ONE


func marcar_completado(color_estela: Color) -> void:
	completado = true
	texture_normal = imagen_color

	estela.visible = true
	estela.modulate = color_estela
	estela.modulate.a = 0.95
	_animar_estela_neon()

	scale = Vector2.ONE
	cuadro_completado.emit(self, emocion_asignada)

	if has_node("JugadorCinematico"):
		$JugadorCinematico.set_emocion(emocion_asignada)
	elif emoji_animado != null:
		emoji_animado.play(emocion_asignada)


func _configurar_estela_inicial() -> void:
	estela.visible = false
	estela.position = Vector2.ZERO
	estela.scale = Vector2.ONE


func _animar_estela_neon() -> void:
	if estela_tween != null:
		estela_tween.kill()

	estela.position = Vector2.ZERO
	estela_tween = create_tween()
	estela_tween.set_loops()
	estela_tween.set_trans(Tween.TRANS_SINE)
	estela_tween.set_ease(Tween.EASE_IN_OUT)

	estela_tween.tween_property(estela, "position", Vector2(5.0, -3.0), 0.6)
	estela_tween.parallel().tween_property(estela, "scale", Vector2(1.03, 1.02), 0.6)
	estela_tween.parallel().tween_property(estela, "modulate:a", 0.82, 0.6)

	estela_tween.tween_property(estela, "position", Vector2(-4.0, 4.0), 0.6)
	estela_tween.parallel().tween_property(estela, "scale", Vector2(1.01, 1.04), 0.6)
	estela_tween.parallel().tween_property(estela, "modulate:a", 0.98, 0.6)

	estela_tween.tween_property(estela, "position", Vector2.ZERO, 0.7)
	estela_tween.parallel().tween_property(estela, "scale", Vector2.ONE, 0.7)
	estela_tween.parallel().tween_property(estela, "modulate:a", 0.9, 0.7)


func _on_resized() -> void:
	_update_layout_overlays()


func _update_layout_overlays() -> void:
	pivot_offset = size / 2.0

	var padding: float = min(size.x, size.y) * 0.05
	estela.anchor_left = 0.0
	estela.anchor_top = 0.0
	estela.anchor_right = 1.0
	estela.anchor_bottom = 1.0
	estela.offset_left = -padding
	estela.offset_top = -padding
	estela.offset_right = padding
	estela.offset_bottom = padding

	if emoji_animado == null:
		return

	emoji_animado.position = size / 2.0
	var referencia: float = max(min(size.x, size.y), 1.0)
	var escala_base: float = referencia / 56.0
	emoji_animado.scale = Vector2.ONE * clamp(escala_base, 1.8, 3.4)
	emoji_animado.play("neutro")
