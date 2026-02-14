extends TextureButton

var hover_tween: Tween = null
var seleccionado: bool = false

@export var emocion_id: String = ""

@onready var selector: Control = find_parent("SelectorEmocion") as Control


func _ready() -> void:
	if emocion_id == "":
		push_warning("EmojiButton sin emocion_id asignado")


func _on_mouse_entered() -> void:
	if hover_tween != null:
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.2)

	if selector != null:
		selector.call("actualizar_preview_emocion", emocion_id)


func _on_mouse_exited() -> void:
	if hover_tween != null:
		hover_tween.kill()

	_actualizar_escala()


func _on_pressed() -> void:
	if selector != null:
		selector.call("seleccionar_emocion", emocion_id, self)


func set_seleccionado(valor: bool) -> void:
	seleccionado = valor
	_actualizar_escala()
	_actualizar_opacidad()


func _actualizar_escala() -> void:
	if seleccionado:
		scale = Vector2(1.2, 1.2)
		return

	scale = Vector2.ONE


func _actualizar_opacidad() -> void:
	if seleccionado:
		modulate.a = 1.0
		return

	modulate.a = 0.8