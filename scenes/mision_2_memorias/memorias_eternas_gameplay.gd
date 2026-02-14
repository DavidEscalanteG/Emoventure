extends Control

const TOTAL_CUADROS: int = 7

@onready var selector: Control = $SelectorEmocion
@onready var cuadros_container: GridContainer = $CuadrosContainer
@onready var puerta: TextureButton = $PuertaCuestionario
@onready var texto_contador: Label = $Contador

var cuadros_completados: int = 0
var respuestas_emociones: Array[String] = []


func _ready() -> void:
	_respuestas_iniciales()
	actualizar_contador()
	
	selector.visible = false
	
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
	for indice in range(TOTAL_CUADROS):
		respuestas_emociones.append("")


func _on_cuadro_completado(cuadro: CuadroMemoria, emocion: String) -> void:
	cuadros_completados += 1
	_guardar_respuesta(cuadro, emocion)
	Logs.log_debug("[DEBUG] Cuadros completados: %d" % cuadros_completados)
	Logs.log_debug("[DEBUG] Respuestas misión 2: %s" % str(respuestas_emociones))
	
	actualizar_contador()
	
	if cuadros_completados >= TOTAL_CUADROS:
		_mostrar_puerta()


func _guardar_respuesta(cuadro: CuadroMemoria, emocion: String) -> void:
	var indice: int = cuadro.get_index()
	if indice < 0 or indice >= respuestas_emociones.size():
		push_warning("Índice de cuadro fuera de rango: %d" % indice)
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
