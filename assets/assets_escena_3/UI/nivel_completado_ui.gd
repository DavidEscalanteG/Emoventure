extends Control

@export var siguiente_escena: String

@onready var emociones := $Panel/VBoxContainer/Emociones.get_children()
@onready var corazones := $Panel/VBoxContainer/Vidas.get_children()
@onready var jugador_grande := $Panel/VBoxContainer/ControlJugador
@onready var boton := $Panel/VBoxContainer/ControlBoton/BotonContinuar

func _ready():
	hide()
	boton.visible = false
	boton.disabled = true
	boton.pressed.connect(_continuar)

func mostrar(emociones_recolectadas: Array, vidas_restantes: int):
	show()

	# Ocultar todo
	for e in emociones:
		e.visible = false
	for c in corazones:
		c.visible = false

	jugador_grande.visible = false
	boton.visible = false
	boton.disabled = true
	
	print("✅")
	await _mostrar_emociones(emociones_recolectadas)
	print("✅✅")
	await _mostrar_vidas(vidas_restantes)
	print("✅✅✅")
	await _mostrar_jugador()
	print("✅✅✅✅")

	boton.visible = true
	print("✅✅✅✅✅")
	boton.disabled = false
	print("✅✅✅✅✅✅")

func _mostrar_emociones(lista: Array):
	for emocion in emociones:
		if emocion.name.to_lower() in lista:
			emocion.visible = true
			emocion.scale = Vector2(0.5, 0.5)

			var tween = create_tween()
			tween.tween_property(emocion, "scale", Vector2.ONE, 0.25)\
				.set_trans(Tween.TRANS_BACK)\
				.set_ease(Tween.EASE_OUT)

			await get_tree().create_timer(0.3).timeout

func _mostrar_vidas(vidas_restantes: int):
	for i in range(vidas_restantes):
		corazones[i].visible = true
		await get_tree().create_timer(0.25).timeout

func _mostrar_jugador():
	jugador_grande.visible = true
	jugador_grande.scale = Vector2(0.8, 0.8)

	var tween = create_tween()
	tween.tween_property(jugador_grande, "scale", Vector2.ONE, 0.4)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	await tween.finished

func _continuar():
	get_tree().change_scene_to_file(siguiente_escena)
