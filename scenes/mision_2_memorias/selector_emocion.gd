extends Control

const EMOCION_NEUTRA: String = "neutro"

var cuadro_actual: CuadroMemoria = null
var emocion_preview: String = ""
var emocion_seleccionada: String = ""
var emocion_confirmada: bool = false
var emoji_seleccionado: TextureButton = null

@onready var visor: TextureRect = $VisorImagen
@onready var emojis_container: Control = $EmojisContainer
@onready var emoji_grande: AnimatedSprite2D = $VisorImagen/EmojiGrande
@onready var boton_confirmar: Button = $BotonConfirmar

var colores_emociones: Dictionary[String, Color] = {
	"felicidad": Color("#FFD966"),
	"tristeza": Color("#6FA8DC"),
	"enojo": Color("#E06666"),
	"asombro": Color("#FFE599"),
	"ansiedad": Color("#8E7CC3"),
	"desagrado": Color("#93C47D"),
	"amor": Color("#F4CCCC")
}


func mostrar(cuadro: CuadroMemoria) -> void:
	Logs.log_debug("[DEBUG] Mostrar selector")

	cuadro_actual = cuadro
	emocion_preview = ""
	emocion_seleccionada = ""
	emocion_confirmada = false
	emoji_seleccionado = null

	for emoji in emojis_container.get_children():
		var boton_emoji: TextureButton = emoji as TextureButton
		if boton_emoji == null:
			continue
		boton_emoji.disabled = false
		if boton_emoji.has_method("set_seleccionado"):
			boton_emoji.call("set_seleccionado", false)

	emojis_container.visible = true
	emojis_container.modulate.a = 1.0
	emojis_container.scale = Vector2.ONE

	visible = true
	modulate.a = 0.0
	var tween_mostrar: Tween = create_tween()
	tween_mostrar.tween_property(self, "modulate:a", 1.0, 0.3)

	emoji_grande.scale = Vector2(4.0, 4.0)
	emoji_grande.play(EMOCION_NEUTRA)

	visor.texture = cuadro.texture_normal
	visor.visible = true
	visor.scale = Vector2(0.7, 0.7)
	visor.modulate.a = 1.0

	boton_confirmar.disabled = true

	var visor_tween: Tween = create_tween()
	visor_tween.set_trans(Tween.TRANS_SINE)
	visor_tween.set_ease(Tween.EASE_OUT)
	visor_tween.tween_property(visor, "scale", Vector2.ONE, 0.4)


func actualizar_preview_emocion(emocion_id: String) -> void:
	if emocion_confirmada:
		return

	if emocion_id == "":
		return

	emocion_preview = emocion_id
	emoji_grande.play(emocion_id)


func restaurar_preview_emocion() -> void:
	if emocion_confirmada:
		return

	if emocion_seleccionada != "":
		emocion_preview = emocion_seleccionada
		emoji_grande.play(emocion_seleccionada)
		return

	emocion_preview = ""
	emoji_grande.play(EMOCION_NEUTRA)


func seleccionar_emocion(emocion_id: String, emoji: TextureButton) -> void:
	if emocion_confirmada:
		return

	Logs.log_debug("[DEBUG] Emoción seleccionada: %s" % emocion_id)

	emocion_seleccionada = emocion_id
	emoji_seleccionado = emoji
	emoji_grande.play(emocion_id)
	boton_confirmar.disabled = false

	for emoji_actual in emojis_container.get_children():
		var boton_emoji: TextureButton = emoji_actual as TextureButton
		if boton_emoji == null:
			continue
		if boton_emoji.has_method("set_seleccionado"):
			boton_emoji.call("set_seleccionado", false)

	if emoji.has_method("set_seleccionado"):
		emoji.call("set_seleccionado", true)


func confirmar_emocion() -> bool:
	if emocion_confirmada:
		Logs.log_debug("[DEBUG] Confirmar ignorado: ya confirmado")
		return false

	if emocion_seleccionada == "":
		Logs.log_debug("[DEBUG] Confirmar ignorado: ninguna emoción seleccionada")
		return false

	Logs.log_debug("[DEBUG] Emoción CONFIRMADA: %s" % emocion_seleccionada)

	emocion_confirmada = true
	cuadro_actual.emocion_asignada = emocion_seleccionada
	var color_estela: Color = Color(colores_emociones[emocion_seleccionada])
	cuadro_actual.marcar_completado(color_estela)

	_ocultar()
	return true


func cancelar_seleccion() -> void:
	Logs.log_debug("[DEBUG] Selección cancelada, cerrando sin guardar")

	emocion_preview = ""
	emocion_seleccionada = ""
	emocion_confirmada = false
	emoji_seleccionado = null
	emoji_grande.play(EMOCION_NEUTRA)

	for emoji in emojis_container.get_children():
		if emoji.has_method("set_seleccionado"):
			emoji.call("set_seleccionado", false)

	_ocultar()


func _ocultar() -> void:
	var tween_ocultar: Tween = create_tween()
	tween_ocultar.tween_property(self, "modulate:a", 0.0, 0.25)
	tween_ocultar.tween_callback(func() -> void:
		visor.visible = false
		hide()
	)
	
