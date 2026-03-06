extends Control

const TOTAL_CUADROS: int = 7
const DURACION_RETROALIMENTACION: float = 4.0

const MENSAJES_RETROALIMENTACION_GENERICO: Array[String] = [
	"Qué interesante...",
	"Ese recuerdo se siente auténtico.",
	"Tu percepción emocional está brillando."
]

const MENSAJES_RETROALIMENTACION_POR_EMOCION: Dictionary = {
	"felicidad": [ 
		"La felicidad refleja que ese momento fue significativo para ti. Reconocerla te permite revivir lo que te hizo bien.",
		"Sentir alegría indica que algo conectó con tus deseos o expectativas. Es importante notar cuándo sucede.",
		"La felicidad puede surgir en instantes simples. Identificarla fortalece tu bienestar.",
		"Esa emoción muestra satisfacción o gratitud. Recordarla puede impulsarte en otros momentos.",
		"La alegría nos ayuda a construir recuerdos positivos. Ser consciente de ella amplía tu autoconocimiento.",
		"Cuando reconoces la felicidad, aprendes qué situaciones nutren tu vida.",
		"Esa emoción puede motivarte a repetir experiencias que te hacen sentir pleno.",
		"La felicidad compartida suele fortalecer vínculos con los demás.",
		"Notar esta emoción te ayuda a valorar tus propios logros.",
		"La alegría también es una señal de equilibrio interno en ese momento."
	],
	"tristeza": [
		"La tristeza puede aparecer cuando algo importante cambia o se pierde.",
		"Sentir tristeza muestra que algo tenía valor para ti.",
		"Esta emoción invita a la reflexión y al descanso emocional.",
		"Reconocer la tristeza es un paso importante para procesarla.",
		"A veces la tristeza nos ayuda a comprender lo que realmente necesitamos.",
		"Identificar esta emoción te permite tratarte con mayor comprensión.",
		"La tristeza también forma parte de la experiencia humana.",
		"Aceptar esta emoción facilita que eventualmente se transforme.",
		"Sentir tristeza no es debilidad, es sensibilidad ante lo vivido.",
		"Notar cuándo estás triste te da la oportunidad de buscar apoyo si lo necesitas."
	],
	"enojo": [
		"El enojo puede surgir cuando percibes injusticia o frustración.",
		"Esta emoción señala que algo no fue como esperabas.",
		"Reconocer el enojo es el primer paso para gestionarlo.",
		"El enojo también puede darte energía para cambiar una situación.",
		"Identificar esta emoción evita que actúe de forma impulsiva.",
		"A veces el enojo protege tus límites personales.",
		"Sentir enojo indica que algo es importante para ti.",
		"Comprender esta emoción te ayuda a expresarte de forma más saludable.",
		"El enojo puede enseñarte qué situaciones te afectan más.",
		"Notar esta emoción te permite decidir cómo responder."
	],
	"asombro": [
		"El asombro surge ante lo inesperado.",
		"Esta emoción despierta curiosidad.",
		"Sentir sorpresa indica que algo rompió tus expectativas.",
		"El asombro puede abrirte a nuevas experiencias.",
		"Reconocer esta emoción fortalece tu capacidad de adaptación.",
		"Lo inesperado también puede convertirse en aprendizaje.",
		"La sorpresa activa tu atención y percepción.",
		"Esta emoción puede mezclarse con otras sensaciones.",
		"Identificar el asombro te ayuda a entender cómo reaccionas ante lo nuevo.",
		"El asombro mantiene viva tu capacidad de maravillarte."
	],
	"ansiedad": [
		"La ansiedad puede aparecer ante situaciones inciertas.",
		"Esta emoción suele anticipar algo importante.",
		"Reconocer la ansiedad te permite prepararte mejor.",
		"A veces la ansiedad surge cuando deseas hacerlo bien.",
		"Identificarla es el primer paso para regularla.",
		"La ansiedad también indica que algo te importa.",
		"Notar esta emoción te ayuda a respirar y detenerte.",
		"La anticipación puede generar tensión interna.",
		"Comprender tu ansiedad te permite actuar con mayor claridad.",
		"Reconocer esta emoción evita que te sobrepase."
	],
	"desagrado": [
		"El desagrado protege de aquello que percibes como negativo.",
		"Esta emoción ayuda a marcar límites.",
		"Sentir desagrado indica que algo no coincide contigo.",
		"Reconocerlo te permite alejarte de lo que te incomoda.",
		"El desagrado es una señal de autoprotección.",
		"Esta emoción puede ayudarte a definir tus preferencias.",
		"Identificarla fortalece tu capacidad de decisión.",
		"El desagrado también es información emocional.",
		"Notar esta emoción te ayuda a cuidar tu bienestar.",
		"Reconocer lo que no te agrada es parte del autoconocimiento."
	],
	"amor": [
		"El amor fortalece vínculos significativos.",
		"Esta emoción refleja conexión y cercanía.",
		"Reconocer el amor te ayuda a valorar tus relaciones.",
		"El amor puede brindar seguridad emocional.",
		"Sentir esta emoción indica afecto genuino.",
		"El amor también impulsa actos de cuidado.",
		"Identificar esta emoción fortalece tu empatía.",
		"El amor puede ser una fuente de motivación.",
		"Reconocerlo te ayuda a comprender lo que es importante para ti.",
		"El amor construye recuerdos duraderos."
	]
}

@onready var selector: Control = $SelectorEmocion
@onready var cuadros_container: GridContainer = $CuadrosContainer
@onready var puerta: TextureButton = $PuertaCuestionario
@onready var texto_contador: Label = $Contador
@onready var texto_retroalimentacion: Label = $Retroalimentacion

var cuadros_completados: int = 0
var respuestas_emociones: Array[String] = []
var cuadros_confirmados: Dictionary = {}
var tween_retroalimentacion: Tween = null


func _ready() -> void:
	_respuestas_iniciales()
	actualizar_contador()

	selector.visible = false
	texto_retroalimentacion.visible = false
	texto_retroalimentacion.modulate.a = 0.0
	texto_retroalimentacion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	puerta.visible = true
	puerta.disabled = true
	puerta.modulate.a = 0.0

	for cuadro in cuadros_container.get_children():
		var cuadro_memoria: CuadroMemoria = cuadro as CuadroMemoria
		if cuadro_memoria == null:
			continue
		cuadro_memoria.cuadro_seleccionado.connect(_on_cuadro_seleccionado)
		cuadro_memoria.cuadro_completado.connect(_on_cuadro_completado)


func _respuestas_iniciales() -> void:
	respuestas_emociones.clear()
	cuadros_confirmados.clear()
	for indice in range(TOTAL_CUADROS):
		respuestas_emociones.append("")


func _on_cuadro_completado(cuadro: CuadroMemoria, emocion: String) -> void:
	if cuadro == null:
		push_warning("Se recibió cuadro nulo en _on_cuadro_completado")
		return

	if cuadros_confirmados.has(cuadro.id_cuadro):
		push_warning("Cuadro ya confirmado: %d" % cuadro.id_cuadro)
		_guardar_respuesta(cuadro, emocion)
		return

	cuadros_confirmados[cuadro.id_cuadro] = true
	cuadros_completados += 1
	_guardar_respuesta(cuadro, emocion)
	Logs.log_debug("[DEBUG] Cuadros completados: %d" % cuadros_completados)
	Logs.log_debug("[DEBUG] Respuestas misión 2: %s" % str(respuestas_emociones))

	actualizar_contador()
	_mostrar_retroalimentacion(emocion)

	if cuadros_completados >= TOTAL_CUADROS:
		_mostrar_puerta()


func _guardar_respuesta(cuadro: CuadroMemoria, emocion: String) -> void:
	if cuadro == null:
		push_warning("Intento de guardar respuesta con cuadro nulo")
		return

	var indice: int = cuadro.id_cuadro
	if indice < 0 or indice >= respuestas_emociones.size():
		push_warning("Índice de cuadro fuera de rango: %d" % indice)
		return

	for otro_cuadro in cuadros_container.get_children():
		var cuadro_memoria: CuadroMemoria = otro_cuadro as CuadroMemoria
		if cuadro_memoria == null or cuadro_memoria == cuadro:
			continue
		if cuadro_memoria.id_cuadro == indice:
			push_warning("ID de cuadro duplicado detectado: %d" % indice)
			return

	respuestas_emociones[indice] = emocion


func _mostrar_puerta() -> void:
	Logs.log_debug("[DEBUG] Todas las emociones reconocidas. Mostrando puerta.")
	puerta.disabled = false

	var tween: Tween = create_tween()
	tween.tween_property(puerta, "modulate:a", 1.0, 0.8)


func _on_cuadro_seleccionado(cuadro: CuadroMemoria) -> void:
	selector.call("mostrar", cuadro)


func actualizar_contador() -> void:
	texto_contador.text = "%d / %d recuerdos explorados" % [cuadros_completados, TOTAL_CUADROS]

	var tween: Tween = create_tween()
	tween.tween_property(texto_contador, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(texto_contador, "scale", Vector2.ONE, 0.1)


func _mostrar_retroalimentacion(emocion: String) -> void:
	if texto_retroalimentacion == null:
		return

	_ocultar_retroalimentacion_inmediata()

	var emocion_normalizada: String = emocion.strip_edges().to_lower()
	var mensajes_emocion: Array[String] = MENSAJES_RETROALIMENTACION_GENERICO
	var mensajes_crudos: Variant = MENSAJES_RETROALIMENTACION_POR_EMOCION.get(emocion_normalizada, [])
	if mensajes_crudos is Array:
		var mensajes_convertidos: Array[String] = []
		for mensaje in mensajes_crudos:
			if mensaje is String:
				mensajes_convertidos.append(mensaje)

		if not mensajes_convertidos.is_empty():
			mensajes_emocion = mensajes_convertidos

	if mensajes_emocion.is_empty():
		mensajes_emocion = MENSAJES_RETROALIMENTACION_GENERICO

	texto_retroalimentacion.text = mensajes_emocion[randi() % mensajes_emocion.size()]
	texto_retroalimentacion.visible = true
	texto_retroalimentacion.modulate.a = 0.0
	texto_retroalimentacion.scale = Vector2(0.95, 0.95)

	tween_retroalimentacion = create_tween()
	tween_retroalimentacion.set_trans(Tween.TRANS_SINE)
	tween_retroalimentacion.set_ease(Tween.EASE_OUT)
	tween_retroalimentacion.tween_property(texto_retroalimentacion, "modulate:a", 1.0, 0.2)
	tween_retroalimentacion.parallel().tween_property(texto_retroalimentacion, "scale", Vector2.ONE, 0.2)
	tween_retroalimentacion.tween_interval(DURACION_RETROALIMENTACION)
	tween_retroalimentacion.set_ease(Tween.EASE_IN)
	tween_retroalimentacion.tween_property(texto_retroalimentacion, "modulate:a", 0.0, 0.3)
	tween_retroalimentacion.tween_callback(func() -> void:
		texto_retroalimentacion.visible = false
	)


func _ocultar_retroalimentacion_inmediata() -> void:
	if tween_retroalimentacion != null:
		tween_retroalimentacion.kill()
		tween_retroalimentacion = null

	texto_retroalimentacion.visible = false
	texto_retroalimentacion.modulate.a = 0.0
