extends Control

const ESCENA_RESULTADO_FINAL: String = "res://scenes/final/resultado_final.tscn"

const MINIJUEGOS: Dictionary[String, String] = {
	"Minijuego2": "res://scenes/mision_2_memorias/mision_2_memorias.tscn",
	"Minijuego3": "res://scenes/mision_3_hachas/mision_3_hachas.tscn",
	"Minijuego4": "res://scenes/mision_4_payasos/mapa_topos.tscn"
}

const BOTON_MINIJUEGO_1: String = "Minijuego1"

@onready var mapa_container: Control = %MapaContainer
@onready var oscurecedor: ColorRect = %Oscurecedor
@onready var fade_negro: ColorRect = %FadeNegro
@onready var boton_volver_resultados: Button = %BotonVolverResultados

var _en_transicion: bool = false


func _ready() -> void:
	for nombre_boton in _obtener_botones_minijuego():
		var boton: BaseButton = get_node_or_null("MapaContainer/%s" % nombre_boton)
		if boton == null:
			push_warning("[mapa_rejugabilidad] No se encontró el botón: %s" % nombre_boton)
			continue
		boton.pressed.connect(_on_localizacion_pressed.bind(nombre_boton))

	boton_volver_resultados.pressed.connect(_on_boton_volver_resultados_pressed)
	_animar_entrada_mapa()


func _animar_entrada_mapa() -> void:
	mapa_container.scale = Vector2(1.05, 1.05)
	mapa_container.modulate = Color(1, 1, 1, 0.0)
	oscurecedor.color = Color(0, 0, 0, 0.0)
	fade_negro.color = Color(0, 0, 0, 0.0)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(mapa_container, "scale", Vector2.ONE, 0.7)
	tween.tween_property(mapa_container, "modulate", Color.WHITE, 0.65)


func _obtener_botones_minijuego() -> Array[String]:
	var botones: Array[String] = MINIJUEGOS.keys()
	botones.append(BOTON_MINIJUEGO_1)
	return botones


func _obtener_destino_minijuego(nombre_boton: String) -> String:
	if nombre_boton == BOTON_MINIJUEGO_1:
		return GameManager.obtener_siguiente_mapa_minijuego_1()
	return MINIJUEGOS.get(nombre_boton, "")


func _on_localizacion_pressed(nombre_boton: String) -> void:
	if _en_transicion:
		return

	var destino: String = _obtener_destino_minijuego(nombre_boton)
	if destino.is_empty():
		push_warning("[mapa_rejugabilidad] No hay destino configurado para: %s" % nombre_boton)
		return

	var boton: Control = get_node_or_null("MapaContainer/%s" % nombre_boton)
	if boton == null:
		get_tree().change_scene_to_file(destino)
		return

	_en_transicion = true
	_bloquear_localizaciones(true)
	AudioManager.play_ui_click()
	_realizar_transicion_a_minijuego(boton, destino)


func _realizar_transicion_a_minijuego(boton_objetivo: Control, destino: String) -> void:
	var centro_viewport: Vector2 = size * 0.5
	var centro_boton: Vector2 = boton_objetivo.global_position + (boton_objetivo.size * 0.5)
	var desplazamiento: Vector2 = (centro_viewport - centro_boton) * 0.35

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	tween.tween_property(mapa_container, "position", desplazamiento, 0.45)
	tween.tween_property(mapa_container, "scale", Vector2(1.15, 1.15), 0.45)
	tween.tween_property(oscurecedor, "color", Color(0, 0, 0, 0.35), 0.45)

	await tween.finished

	var fade_tween: Tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_SINE)
	fade_tween.set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(fade_negro, "color", Color(0, 0, 0, 1), 0.4)
	await fade_tween.finished

	get_tree().change_scene_to_file(destino)


func _bloquear_localizaciones(bloquear: bool) -> void:
	for nombre_boton in _obtener_botones_minijuego():
		var boton: BaseButton = get_node_or_null("MapaContainer/%s" % nombre_boton)
		if boton != null:
			boton.disabled = bloquear


func _on_boton_volver_resultados_pressed() -> void:
	if _en_transicion:
		return
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file(ESCENA_RESULTADO_FINAL)
