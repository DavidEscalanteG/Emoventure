extends Node

var puntaje_total: int = 0
const ESCENA_MAPA_REJUGABILIDAD: String = "res://scenes/rejugabilidad/mapa_rejugabilidad.tscn"

const MAPAS_MINIJUEGO_1: Array[String] = [
	"res://scenes/mision_1_recoleccion/mapa_1/mision_1_recoleccion.tscn",
	"res://scenes/mision_1_recoleccion/mapa_2/mapa2.tscn",
	"res://scenes/mision_1_recoleccion/mapa_3/mapa3.tscn",
	"res://scenes/mision_1_recoleccion/mapa_4/mapa4.tscn",
	"res://scenes/mision_1_recoleccion/mapa_5/mapa5.tscn"
]

var puntajes_por_dimension: Dictionary[String, int] = {
	"atencion": 0,
	"claridad": 0,
	"reparacion": 0
}

var _mapas_minijuego_1_jugados: Array[String] = []
var _modo_rejugabilidad_activo: bool = false


func _ready() -> void:
	randomize()

func agregar_puntaje(dimension: String, valor: int) -> void:
	if not puntajes_por_dimension.has(dimension):
		push_warning("[GameManager] Dimensión desconocida: %s" % dimension)
		return

	puntaje_total += valor
	puntajes_por_dimension[dimension] += valor


func obtener_puntaje_total() -> int:
	return puntaje_total


func obtener_puntajes_por_dimension() -> Dictionary[String, int]:
	return puntajes_por_dimension.duplicate(true)


func reiniciar_puntajes() -> void:
	puntaje_total = 0
	for dimension in puntajes_por_dimension.keys():
		puntajes_por_dimension[dimension] = 0


func obtener_siguiente_mapa_minijuego_1() -> String:
	if MAPAS_MINIJUEGO_1.is_empty():
		push_warning("[GameManager] No hay mapas configurados para el minijuego 1")
		return ""

	if _mapas_minijuego_1_jugados.size() >= MAPAS_MINIJUEGO_1.size():
		_mapas_minijuego_1_jugados.clear()

	var candidatos: Array[String] = []
	for mapa in MAPAS_MINIJUEGO_1:
		if not _mapas_minijuego_1_jugados.has(mapa):
			candidatos.append(mapa)

	if candidatos.is_empty():
		candidatos = MAPAS_MINIJUEGO_1.duplicate()

	var mapa_seleccionado: String = candidatos[randi_range(0, candidatos.size() - 1)]
	_mapas_minijuego_1_jugados.append(mapa_seleccionado)
	return mapa_seleccionado


func reiniciar_rotacion_mapas_minijuego_1() -> void:
	_mapas_minijuego_1_jugados.clear()


func activar_modo_rejugabilidad() -> void:
	_modo_rejugabilidad_activo = true


func desactivar_modo_rejugabilidad() -> void:
	_modo_rejugabilidad_activo = false


func consumir_modo_rejugabilidad() -> bool:
	var estaba_activo: bool = _modo_rejugabilidad_activo
	_modo_rejugabilidad_activo = false
	return estaba_activo
