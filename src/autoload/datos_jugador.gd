extends Node
#Este es el global
signal todas_las_emociones_recolectadas

var jugador: CharacterBody2D
var emotions_ui: Node = null

var genero: String = "hombre"

const GENERO_HOMBRE := "hombre"
const GENERO_MUJER := "mujer"

const RANGO_CABELLO_HOMBRE := Vector2i(0, 17)
const RANGO_CABELLO_MUJER := Vector2i(18, 34)

## ---------------------------------------------------------------------------
## DEPRECADO (TRANSICIÓN): Puntajes ahora viven en GameManager
## Mantener este wrapper evita romper scenes/scripts antiguos.
## ---------------------------------------------------------------------------
func agregar_puntaje(dimension: String, valor: int) -> void:
	push_warning("[DatosJugador] agregar_puntaje está deprecado. Usa GameManager.agregar_puntaje().")
	GameManager.agregar_puntaje(dimension, valor)


func obtener_puntaje_total() -> int:
	return GameManager.obtener_puntaje_total()


func obtener_puntajes_por_dimension() -> Dictionary:
	return GameManager.obtener_puntajes_por_dimension()

const EMOCIONES_TOTALES: Array[String] = [
	"alegria",
	"tristeza",
	"enojo",
	"desagrado",
	"miedo"
]

var emociones_recolectadas: Array[String] = []

var lives_ui: Node = null



func reiniciar_estado_temporal() -> void:
	emociones_recolectadas.clear()
	jugador = null
	emotions_ui = null
	lives_ui = null

	
func registrar_emocion(emocion: String) -> void:
	if emociones_recolectadas.has(emocion):
		return

	emociones_recolectadas.append(emocion)

	if tiene_todas_las_emociones():
		todas_las_emociones_recolectadas.emit()

func tiene_todas_las_emociones() -> bool:
	return emociones_recolectadas.size() == EMOCIONES_TOTALES.size()

var apariencia: AparienciaJugador = AparienciaJugador.new()
var mascota: MascotaSeleccion = MascotaSeleccion.new()

func set_genero(nuevo_genero: String) -> void:
	if nuevo_genero != GENERO_HOMBRE and nuevo_genero != GENERO_MUJER:
		return

	genero = nuevo_genero
	set_indice_cabello(apariencia.indice_cabello)


func obtener_rango_cabello_por_genero(valor_genero: String = genero) -> Vector2i:
	if valor_genero == GENERO_MUJER:
		return RANGO_CABELLO_MUJER
	return RANGO_CABELLO_HOMBRE


func obtener_indice_cabello_inicio(valor_genero: String = genero) -> int:
	return obtener_rango_cabello_por_genero(valor_genero).x


func obtener_indice_cabello_fin(valor_genero: String = genero) -> int:
	return obtener_rango_cabello_por_genero(valor_genero).y


func validar_indice_cabello_por_genero(indice: int, valor_genero: String = genero) -> int:
	var rango := obtener_rango_cabello_por_genero(valor_genero)
	if indice < rango.x or indice > rango.y:
		return rango.x
	return indice


func set_indice_cabello(indice: int) -> void:
	apariencia.indice_cabello = validar_indice_cabello_por_genero(indice)


func avanzar_indice_cabello() -> int:
	var rango := obtener_rango_cabello_por_genero()
	var indice := apariencia.indice_cabello + 1
	if indice > rango.y:
		indice = rango.x
	set_indice_cabello(indice)
	return apariencia.indice_cabello


func retroceder_indice_cabello() -> int:
	var rango := obtener_rango_cabello_por_genero()
	var indice := apariencia.indice_cabello - 1
	if indice < rango.x:
		indice = rango.y
	set_indice_cabello(indice)
	return apariencia.indice_cabello


func set_indice_mascota(indice: int) -> void:
	mascota.indice = max(indice, 0)


func obtener_indice_mascota() -> int:
	return mascota.indice


func avanzar_indice_mascota(total_mascotas: int) -> int:
	if total_mascotas <= 0:
		return mascota.indice
	mascota.indice = (mascota.indice + 1) % total_mascotas
	return mascota.indice


func retroceder_indice_mascota(total_mascotas: int) -> int:
	if total_mascotas <= 0:
		return mascota.indice

	mascota.indice -= 1
	if mascota.indice < 0:
		mascota.indice = total_mascotas - 1

	return mascota.indice


func reiniciar_indices_apariencia() -> void:
	apariencia.indice_cabeza = 0
	apariencia.indice_ojos = 0
	apariencia.indice_boca = 0
	apariencia.indice_cuerpo = 0
	apariencia.indice_nariz = 0


func tiene_clave_color_apariencia(clave: String) -> bool:
	return clave in [
		"color_cabeza",
		"color_cabello",
		"color_ojos",
		"color_cuerpo",
		"color_nariz",
		"color_boca"
	]


func obtener_color_apariencia(clave: String) -> Color:
	match clave:
		"color_cabeza":
			return apariencia.color_cabeza
		"color_cabello":
			return apariencia.color_cabello
		"color_ojos":
			return apariencia.color_ojos
		"color_cuerpo":
			return apariencia.color_cuerpo
		"color_nariz":
			return apariencia.color_nariz
		"color_boca":
			return apariencia.color_boca
		_:
			return Color.WHITE


func set_color_apariencia(clave: String, color: Color) -> bool:
	match clave:
		"color_cabeza":
			apariencia.color_cabeza = color
		"color_cabello":
			apariencia.color_cabello = color
		"color_ojos":
			apariencia.color_ojos = color
		"color_cuerpo":
			apariencia.color_cuerpo = color
		"color_nariz":
			apariencia.color_nariz = color
		"color_boca":
			apariencia.color_boca = color
		_:
			return false
	return true
