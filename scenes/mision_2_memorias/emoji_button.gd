extends TextureButton

# ==================================================
# ESTADO
# ==================================================
var hover_tween: Tween
var seleccionado: bool = false


# ==================================================
# CONFIG
# ==================================================
@export var emocion_id: String


# ==================================================
# REFERENCIAS
# ==================================================
@onready var selector: Node = find_parent("SelectorEmocion")


func _ready() -> void:
	if emocion_id == "":
		push_warning("EmojiButton sin emocion_id asignado")

# ==================================================
# HOVER
# ==================================================
func _on_mouse_entered() -> void:
	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.2)

	if selector:
		selector.actualizar_cara(null, emocion_id)


func _on_mouse_exited() -> void:
	if hover_tween:
		hover_tween.kill()

	_actualizar_escala()

	if selector:
		selector.actualizar_cara(null, "")


# ==================================================
# CLICK
# ==================================================
func _on_pressed() -> void:
	if selector:
		selector.seleccionar_emocion(emocion_id, self)


# ==================================================
# SELECCIÓN VISUAL
# ==================================================
func set_seleccionado(valor: bool) -> void:
	seleccionado = valor
	_actualizar_escala()
	_actualizar_opacidad()


func _actualizar_escala() -> void:
	if seleccionado:
		scale = Vector2(1.2, 1.2)
	else:
		scale = Vector2.ONE


func _actualizar_opacidad() -> void:
	if seleccionado:
		modulate.a = 1.0
	else:
		modulate.a = 0.8
