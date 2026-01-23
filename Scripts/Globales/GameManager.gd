extends Node

var puntaje_total := 0

var puntajes_por_dimension := {
	"atencion": 0,
	"claridad": 0,
	"reparacion": 0
}

func agregar_puntaje(dimension: String, valor: int) -> void:
	puntaje_total += valor
	puntajes_por_dimension[dimension] += valor
