extends Control
## Guía decorativa: no intercepta el clic ni modifica la zona táctil de la puerta.

const MANO_TOCAR: Texture2D = preload("res://assets/assets_escena_9/puerta/mano_tocar.svg")
const DURACION_CICLO: float = 3.6
const COLOR_DORADO: Color = Color("#ffd779")
const ANCHOS_HALO: Array[float] = [52.0, 34.0, 18.0, 4.0]
const ALFAS_HALO: Array[float] = [0.035, 0.065, 0.13, 0.65]

var zona_puerta: Rect2 = Rect2()
var _tiempo: float = 0.0
var _resaltada: bool = false
var _mano: TextureRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mano = TextureRect.new()
	_mano.name = "ManoTocar"
	_mano.texture = MANO_TOCAR
	_mano.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mano.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mano.size = Vector2(76.0, 92.0)
	_mano.hide()
	add_child(_mano)
	set_process(false)
	hide()


func iniciar(zona: Rect2) -> void:
	zona_puerta = zona
	_tiempo = 0.0
	show()
	set_process(true)
	queue_redraw()


func resaltar(activa: bool) -> void:
	_resaltada = activa
	queue_redraw()


func detener() -> void:
	set_process(false)
	hide()


func _process(delta: float) -> void:
	_tiempo += delta
	var fase: float = fmod(_tiempo, DURACION_CICLO)
	var aparece: float = smoothstep(0.35, 0.65, fase)
	var desaparece: float = 1.0 - smoothstep(2.1, 2.5, fase)
	var toque: float = _intensidad_toque(fase, 0.95) + _intensidad_toque(fase, 1.65)
	_mano.visible = aparece * desaparece > 0.0
	_mano.modulate.a = aparece * desaparece
	# La punta del índice coincide con el origen de los anillos al tocar.
	_mano.position = _punto_toque() - Vector2(26.0, 8.0) + Vector2(8.0, 12.0) * (1.0 - toque)
	queue_redraw()


func _intensidad_toque(fase: float, instante: float) -> float:
	return maxf(0.0, 1.0 - absf(fase - instante) / 0.18)


func _punto_toque() -> Vector2:
	return zona_puerta.position + zona_puerta.size * Vector2(0.57, 0.47)


func _draw() -> void:
	if zona_puerta.size == Vector2.ZERO:
		return
	var pulso: float = (sin(_tiempo * TAU / 2.8) + 1.0) * 0.5
	var intensidad: float = 0.65 + pulso * 0.35 + (0.35 if _resaltada else 0.0)
	var arco: PackedVector2Array = _crear_arco(zona_puerta.grow(7.0))
	for capa: int in range(4):
		draw_polyline(arco, Color(COLOR_DORADO, ALFAS_HALO[capa] * intensidad), ANCHOS_HALO[capa], true)
	var fase: float = fmod(_tiempo, DURACION_CICLO)
	for instante: float in [0.95, 1.65]:
		var avance: float = (fase - instante) / 0.65
		if avance >= 0.0 and avance <= 1.0:
			draw_arc(_punto_toque(), lerpf(10.0, 42.0, avance), 0.0, TAU, 40,
				Color(COLOR_DORADO, (1.0 - avance) * 0.95), 3.0, true)


func _crear_arco(zona: Rect2) -> PackedVector2Array:
	var radio: float = zona.size.x * 0.5
	var centro: Vector2 = Vector2(zona.get_center().x, zona.position.y + radio)
	var puntos: PackedVector2Array = PackedVector2Array()
	puntos.append(Vector2(zona.position.x, zona.end.y))
	for paso: int in range(33):
		var angulo: float = PI + PI * float(paso) / 32.0
		puntos.append(centro + Vector2(cos(angulo), sin(angulo)) * radio)
	puntos.append(zona.end)
	puntos.append(Vector2(zona.position.x, zona.end.y))
	return puntos
