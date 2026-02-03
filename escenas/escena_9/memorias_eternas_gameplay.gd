extends Control

@onready var selector := $SelectorEmocion
@onready var cuadros_container := $CuadrosContainer
@onready var puerta: TextureButton = $PuertaCuestionario
@onready var texto_contador := $Contador

var cuadros_completados: int = 0
const TOTAL_CUADROS: int = 7

func _ready():
	
	actualizar_contador()
	
	selector.visible = false
	
	puerta.visible = true
	puerta.disabled = true
	puerta.modulate.a = 0.0
	
	for cuadro in cuadros_container.get_children():
		cuadro.cuadro_seleccionado.connect(_on_cuadro_seleccionado)
		cuadro.connect("cuadro_completado", Callable(self, "_on_cuadro_completado"))

func _on_cuadro_completado() -> void:
	cuadros_completados += 1
	print("[DEBUG] Cuadros completados:", cuadros_completados)
	
	actualizar_contador()
	
	if cuadros_completados >= TOTAL_CUADROS:
		_mostrar_puerta()

func _mostrar_puerta() -> void:
	print("[DEBUG] Todas las emociones reconocidas. Mostrando puerta.")

	puerta.disabled = false

	var tween := create_tween()
	tween.tween_property(puerta, "modulate:a", 1.0, 0.8)


func _on_cuadro_seleccionado(cuadro):
	selector.mostrar(cuadro)

func actualizar_contador() -> void:
	texto_contador.text = "%d / %d recuerdos explorados" % [
		cuadros_completados,
		TOTAL_CUADROS
	]

	var t := create_tween()
	t.tween_property(texto_contador, "scale", Vector2(1.1, 1.1), 0.1)
	t.tween_property(texto_contador, "scale", Vector2.ONE, 0.1)
