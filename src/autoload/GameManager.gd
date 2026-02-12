extends Node

var puntaje_total := 0

var puntajes_por_dimension := {
	"atencion": 0,
	"claridad": 0,
	"reparacion": 0
}

func agregar_puntaje(dimension: String, valor: int) -> void:
	if not puntajes_por_dimension.has(dimension):
		push_warning("[GameManager] Dimensión desconocida: %s" % dimension)
		return

	puntaje_total += valor
	puntajes_por_dimension[dimension] += valor


func obtener_puntaje_total() -> int:
	return puntaje_total


func obtener_puntajes_por_dimension() -> Dictionary:
	return puntajes_por_dimension.duplicate(true)


func reiniciar_puntajes() -> void:
	puntaje_total = 0
	for dimension in puntajes_por_dimension.keys():
		puntajes_por_dimension[dimension] = 0
