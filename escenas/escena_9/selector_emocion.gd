extends Control

# ==================================================
# ESTADO
# ==================================================
var cuadro_actual: Node = null

var emocion_preview: String = ""
var emocion_seleccionada: String = ""
var emocion_confirmada: bool = false

var emoji_seleccionado: Node = null


# ==================================================
# REFERENCIAS
# ==================================================
@onready var visor: TextureRect = $VisorImagen
@onready var fondo: ColorRect = $FondoOscuro
@onready var emojis_container: Control = $EmojisContainer
@onready var jugador_preview: CharacterBody2D = $JugadorPreview


# ==================================================
# CONFIG
# ==================================================
var colores_emociones: Dictionary = {
	"felicidad": Color("#FFD966"),
	"tristeza": Color("#6FA8DC"),
	"enojo": Color("#E06666"),
	"asombro": Color("#FFE599"),
	"ansiedad": Color("#8E7CC3"),
	"desagrado": Color("#93C47D"),
	"amor": Color("#F4CCCC")
}


# ==================================================
# MOSTRAR SELECTOR
# ==================================================
func mostrar(cuadro: Node) -> void:
	print("[DEBUG] Mostrar selector")

	cuadro_actual = cuadro
	emocion_preview = ""
	emocion_seleccionada = ""
	emocion_confirmada = false
	emoji_seleccionado = null

	# ---- RESET EMOJIS ----
	for emoji in emojis_container.get_children():
		emoji.disabled = false
		emoji.set_seleccionado(false)

	emojis_container.visible = true
	emojis_container.modulate.a = 1.0
	emojis_container.scale = Vector2.ONE

	# ---- MOSTRAR SELECTOR ----
	visible = true
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.3)

	# ---- JUGADOR PREVIEW ----
	jugador_preview.set_emocion("ninguna")
	jugador_preview.scale = Vector2(7,7)

	# ---- VISOR DE IMAGEN ----
	visor.texture = cuadro.texture_normal
	visor.visible = true
	visor.scale = Vector2(0.7, 0.7)
	visor.modulate.a = 1.0
	
	# ---- ACTIVAR BOTON ----
	var boton_confirmar := $BotonConfirmar
	boton_confirmar.disabled = false

	var visor_tween := create_tween()
	visor_tween.set_trans(Tween.TRANS_SINE)
	visor_tween.set_ease(Tween.EASE_OUT)
	visor_tween.tween_property(visor, "scale", Vector2.ONE, 0.4)


# ==================================================
# PREVIEW (HOVER)
# ==================================================
func actualizar_cara(_textura: Texture2D, emocion_id: String) -> void:
	if emocion_confirmada:
		print("[DEBUG] Preview ignorado (confirmado)")
		return

	if emocion_id == "":
		print("[DEBUG] Salir hover")

		if emocion_seleccionada != "":
			jugador_preview.set_emocion(emocion_seleccionada)
		else:
			jugador_preview.set_emocion("ninguna")

		emocion_preview = ""
		return

	print("[DEBUG] Preview emoción:", emocion_id)
	emocion_preview = emocion_id
	jugador_preview.set_emocion(emocion_id)


# ==================================================
# SELECCIÓN (CLICK EN EMOJI)
# ==================================================
func seleccionar_emocion(emocion_id: String, emoji: Node) -> void:
	if emocion_confirmada:
		return

	print("[DEBUG] Emoción seleccionada:", emocion_id)

	emocion_seleccionada = emocion_id
	emoji_seleccionado = emoji

	jugador_preview.set_emocion(emocion_id)

	for e in emojis_container.get_children():
		e.set_seleccionado(false)

	emoji.set_seleccionado(true)


# ==================================================
# CONFIRMAR
# ==================================================
func confirmar_emocion() -> void:
	
	if emocion_confirmada:
		print("[DEBUG] Confirmar ignorado: ya confirmado")
		return
	
	if emocion_seleccionada == "":
		print("[DEBUG] Confirmar ignorado: ninguna emoción seleccionada")
		return

	print("[DEBUG] Emoción CONFIRMADA:", emocion_seleccionada)

	emocion_confirmada = true

	cuadro_actual.emocion_asignada = emocion_seleccionada
	cuadro_actual.marcar_completado(colores_emociones[emocion_seleccionada])

	jugador_preview.confirmar_emocion_visual()
	_ocultar()

# ==================================================
# CANCELAR (BOTÓN ESC / VOLVER)
# ==================================================
func cancelar_seleccion() -> void:
	print("[DEBUG] Selección cancelada, cerrando sin guardar")

	# Reiniciar estado interno
	emocion_preview = ""
	emocion_seleccionada = ""
	emocion_confirmada = false
	emoji_seleccionado = null

	# Volver jugador a estado neutro
	jugador_preview.set_emocion("ninguna")

	# Quitar resaltado de emojis
	for e in emojis_container.get_children():
		e.set_seleccionado(false)

	# Cerrar selector visualmente
	_ocultar()


func _ocultar() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.25)
	t.tween_callback(func():
		visor.visible = false
		hide()
	)
