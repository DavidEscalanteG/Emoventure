extends Node2D
var DatosJugador: Object = Engine.get_singleton("DatosJugador") if Engine.has_singleton("DatosJugador") else null


# --------------------------------------------------
# REFERENCIAS
# --------------------------------------------------

@onready var apariencia: Node2D = $Jugador/PlayerAppearance
@onready var mascota: Node2D = $Mascota

# --------------------------------------------------
# ESTADO TEMPORAL (índices del menú)
# --------------------------------------------------

var indice_cabello: int = 0
var indice_ojos: int = 0
var indice_boca: int = 0
var indice_cuerpo: int = 0
var indice_nariz: int = 0
var indice_cabeza: int = 0


# --------------------------------------------------
# CICLO DE VIDA
# --------------------------------------------------

func _ready() -> void:
	cargar_desde_global()
	_validar_cabello_por_genero()
	refrescar_preview()
	
	mascota.aplicar_mascota_desde_global()


# --------------------------------------------------
# SINCRONIZACIÓN
# --------------------------------------------------

func cargar_desde_global() -> void:
	indice_cabello = DatosJugador.apariencia.indice_cabello
	indice_ojos = DatosJugador.apariencia.indice_ojos
	indice_boca = DatosJugador.apariencia.indice_boca
	indice_cuerpo = DatosJugador.apariencia.indice_cuerpo
	indice_nariz = DatosJugador.apariencia.indice_nariz
	indice_cabeza = DatosJugador.apariencia.indice_cabeza


func guardar_en_global() -> void:
	DatosJugador.set_indice_cabello(indice_cabello)
	DatosJugador.apariencia.indice_ojos = indice_ojos
	DatosJugador.apariencia.indice_boca = indice_boca
	DatosJugador.apariencia.indice_cuerpo = indice_cuerpo
	DatosJugador.apariencia.indice_nariz = indice_nariz
	DatosJugador.apariencia.indice_cabeza = indice_cabeza


func refrescar_preview() -> void:
	guardar_en_global()
	apariencia.aplicar_apariencia_desde_global()


# --------------------------------------------------
# UTILIDADES DE ÍNDICES
# --------------------------------------------------

func _siguiente(indice: int, coleccion: Array) -> int:
	if coleccion.is_empty():
		return indice
	return (indice + 1) % coleccion.size()

func _anterior(indice: int, coleccion: Array) -> int:
	if coleccion.is_empty():
		return indice
	indice -= 1
	return indice if indice >= 0 else coleccion.size() - 1


# --------------------------------------------------
# BOTONES – PARTES DEL CUERPO
# --------------------------------------------------

func _on_btn_cabello_siguiente_pressed() -> void:
	indice_cabello = DatosJugador.avanzar_indice_cabello()
	refrescar_preview()

func _on_btn_cabello_atras_pressed() -> void:
	indice_cabello = DatosJugador.retroceder_indice_cabello()
	refrescar_preview()


func _on_btn_cabeza_siguiente_pressed() -> void:
	indice_cabeza = _siguiente(indice_cabeza, apariencia.coleccion_cabezas)
	refrescar_preview()

func _on_btn_cabeza_atras_pressed() -> void:
	indice_cabeza = _anterior(indice_cabeza, apariencia.coleccion_cabezas)
	refrescar_preview()


func _on_btn_ojos_siguiente_pressed() -> void:
	indice_ojos = _siguiente(indice_ojos, apariencia.coleccion_ojos)
	refrescar_preview()

func _on_btn_ojos_atras_pressed() -> void:
	indice_ojos = _anterior(indice_ojos, apariencia.coleccion_ojos)
	refrescar_preview()


func _on_btn_nariz_siguiente_pressed() -> void:
	indice_nariz = _siguiente(indice_nariz, apariencia.coleccion_narices)
	refrescar_preview()

func _on_btn_nariz_atras_pressed() -> void:
	indice_nariz = _anterior(indice_nariz, apariencia.coleccion_narices)
	refrescar_preview()


func _on_btn_boca_siguiente_pressed() -> void:
	indice_boca = _siguiente(indice_boca, apariencia.coleccion_bocas)
	refrescar_preview()

func _on_btn_boca_atras_pressed() -> void:
	indice_boca = _anterior(indice_boca, apariencia.coleccion_bocas)
	refrescar_preview()


func _on_btn_cuerpo_siguiente_pressed() -> void:
	indice_cuerpo = _siguiente(indice_cuerpo, apariencia.coleccion_cuerpos)
	refrescar_preview()
func _on_btn_cuerpo_atras_pressed() -> void:
	indice_cuerpo = _anterior(indice_cuerpo, apariencia.coleccion_cuerpos)
	refrescar_preview()


# --------------------------------------------------
# COLOR PICKERS
# --------------------------------------------------

func _on_color_picker_button_cabeza_color_changed(color: Color) -> void:
	DatosJugador.apariencia.color_cabeza = color
	apariencia.restaurar_colores()

func _on_color_picker_button_ojos_color_changed(color: Color) -> void:
	DatosJugador.apariencia.color_ojos = color
	apariencia.restaurar_colores()

func _on_color_picker_button_boca_color_changed(color: Color) -> void:
	DatosJugador.apariencia.color_boca = color
	apariencia.restaurar_colores()

func _on_color_picker_button_cuerpo_color_changed(color: Color) -> void:
	DatosJugador.apariencia.color_cuerpo = color
	apariencia.restaurar_colores()

# --------------------------------------------------
# BOTÓN FINAL
# --------------------------------------------------

func _on_comenzar_pressed() -> void:
	guardar_en_global()
	get_tree().change_scene_to_file("uid://dlfpd1a8lfh5") #intro_dialogo_1.tscn


func _on_mascota_siguiente_pressed() -> void:
	_actualizar_indice_mascota(1)


func mascota_anterior() -> void:
	# Compatibilidad temporal: usar _actualizar_indice_mascota(-1).
	_actualizar_indice_mascota(-1)


func _on_mascota_anterior_pressed() -> void:
	mascota_anterior()


func _actualizar_indice_mascota(delta: int) -> void:
	if mascota.coleccion_mascotas.is_empty():
		return

	var indice: int = DatosJugador.obtener_indice_mascota()
	indice = (indice + delta) % mascota.coleccion_mascotas.size()

	if indice < 0:
		indice += mascota.coleccion_mascotas.size()

	DatosJugador.set_indice_mascota(indice)
	mascota.aplicar_mascota_desde_global()

func _validar_cabello_por_genero() -> void:
	if DatosJugador.genero == "":
		return
	
	var rango: Vector2i = DatosJugador.obtener_rango_cabello_por_genero(DatosJugador.genero)
	
	if indice_cabello < rango.x or indice_cabello > rango.y:
		DatosJugador.set_indice_cabello(rango.x)
		indice_cabello = DatosJugador.apariencia.indice_cabello
