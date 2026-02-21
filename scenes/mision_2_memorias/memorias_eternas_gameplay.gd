extends Control

const TOTAL_CUADROS: int = 7
const DURACION_RETROALIMENTACION: float = 2.2

const MENSAJES_RETROALIMENTACION: Array[String] = [
	"Qué interesante...",
	"Buena emoción...",
	"Gran elección emocional.",
	"Ese recuerdo se siente auténtico.",
	"Tu percepción emocional está brillando."
]

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

	if tween_retroalimentacion != null:
		tween_retroalimentacion.kill()

	var emocion_legible: String = emocion.capitalize()
	var mensaje_base: String = MENSAJES_RETROALIMENTACION[randi() % MENSAJES_RETROALIMENTACION.size()]
	texto_retroalimentacion.text = "%s %s" % [mensaje_base, emocion_legible]
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
