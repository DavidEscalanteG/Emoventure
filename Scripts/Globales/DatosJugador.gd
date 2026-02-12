extends Node
#Este es el global
signal todas_las_emociones_recolectadas

var jugador: CharacterBody2D
var emotions_ui: Node = null

var genero: String = "hombre"

const RANGO_CABELLO = {
	"hombre": { "inicio": 0, "fin": 17 },
	"mujer":  { "inicio": 18, "fin": 34 }
}

## ---------------------------------------------------------------------------
## DEPRECADO (TRANSICIÓN): Puntajes ahora viven en GameManager
## Mantener este wrapper evita romper escenas/scripts antiguos.
## ---------------------------------------------------------------------------
func agregar_puntaje(dimension: String, valor: int) -> void:
	push_warning("[Global] agregar_puntaje está deprecado. Usa GameManager.agregar_puntaje().")
	GameManager.agregar_puntaje(dimension, valor)


func obtener_puntaje_total() -> int:
	return GameManager.obtener_puntaje_total()


func obtener_puntajes_por_dimension() -> Dictionary:
	return GameManager.obtener_puntajes_por_dimension()

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
	"indice_cabello": 1,
	"indice_ojos": 0,
	"indice_boca": 0,
	"indice_cuerpo": 0,
	"indice_nariz": 0,
	"indice_cabeza": 0,
	
	# --- AQUÍ CAMBIAS LOS COLORES DEFAULT ---
	
	# Opción A: Usar código Hexadecimal (Recomendado para tonos exactos)
	"color_cabeza": Color("ffcea8"),  # Tono de piel vainilla
	#"color_cabello": Color("ffffffff"), # Marrón muy oscuro (casi negro)
	"color_cabello": Color.from_hsv(
	0.08,   # Hue (marrón)
	0.75,   # Saturation inicial 👈
	0.35    # Value (oscuro, tipo Stardew)
	),

	
	# Opción B: Usar colores estándar de Godot
	"color_ojos": Color("2b2afbff"),         # Azul
	"color_cuerpo": Color("ffffffff"),        # Ropa roja
	
	# Opción C: Usar RGB (Rojo, Verde, Azul) del 0.0 al 1.0
	"color_nariz": Color("ffcea8"),   # Igual que la piel
	"color_boca": Color(1, 1, 1)      # Blanco (Color original del sprite)
}

var mascota = {
	"indice": 0
}
