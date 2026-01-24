extends Node
#Este es el global
signal todas_las_emociones_recolectadas

var jugador: CharacterBody2D
var emotions_ui: Node = null

var puntaje_total := 0

var puntajes_por_dimension := {
	"atencion": 0,
	"claridad": 0,
	"reparacion": 0
}

func agregar_puntaje(dimension: String, valor: int):
	puntaje_total += valor
	puntajes_por_dimension[dimension] += valor

const EMOCIONES_TOTALES := [
	"alegria",
	"tristeza",
	"enojo",
	"desagrado",
	"miedo"
]

var emociones_recolectadas: Array[String] = []

var lives_ui: Node = null

func registrar_emocion(emocion: String):
	if emociones_recolectadas.has(emocion):
		return

	emociones_recolectadas.append(emocion)

	if tiene_todas_las_emociones():
		todas_las_emociones_recolectadas.emit()

func tiene_todas_las_emociones() -> bool:
	return emociones_recolectadas.size() == EMOCIONES_TOTALES.size()

var apariencia = {
	"indice_cabello": 0,
	"indice_ojos": 0,
	"indice_boca": 0,
	"indice_cuerpo": 0,
	"indice_nariz": 0,
	"indice_cabeza": 0,
	
	# --- AQUÍ CAMBIAS LOS COLORES DEFAULT ---
	
	# Opción A: Usar código Hexadecimal (Recomendado para tonos exactos)
	"color_cabeza": Color("ffcea8"),  # Tono de piel vainilla
	"color_cabello": Color("2e1a06"), # Marrón muy oscuro (casi negro)
	
	# Opción B: Usar colores estándar de Godot
	"color_ojos": Color.BLUE,         # Azul
	"color_cuerpo": Color.RED,        # Ropa roja
	
	# Opción C: Usar RGB (Rojo, Verde, Azul) del 0.0 al 1.0
	"color_nariz": Color("ffcea8"),   # Igual que la piel
	"color_boca": Color(1, 1, 1)      # Blanco (Color original del sprite)
}
