extends Node2D

# --------------------------------------------------
# REFERENCIAS
# --------------------------------------------------

@onready var apariencia: Node2D = $Jugador/PlayerAppearance


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
	refrescar_preview()


# --------------------------------------------------
# SINCRONIZACIÓN
# --------------------------------------------------

func cargar_desde_global() -> void:
	indice_cabello = Global.apariencia.indice_cabello
	indice_ojos = Global.apariencia.indice_ojos
	indice_boca = Global.apariencia.indice_boca
	indice_cuerpo = Global.apariencia.indice_cuerpo
	indice_nariz = Global.apariencia.indice_nariz
	indice_cabeza = Global.apariencia.indice_cabeza


func guardar_en_global() -> void:
	Global.apariencia.indice_cabello = indice_cabello
	Global.apariencia.indice_ojos = indice_ojos
	Global.apariencia.indice_boca = indice_boca
	Global.apariencia.indice_cuerpo = indice_cuerpo
	Global.apariencia.indice_nariz = indice_nariz
	Global.apariencia.indice_cabeza = indice_cabeza


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
	indice_cabello = _siguiente(indice_cabello, apariencia.coleccion_cabellos)
	refrescar_preview()

func _on_btn_cabello_atras_pressed() -> void:
	indice_cabello = _anterior(indice_cabello, apariencia.coleccion_cabellos)
	refrescar_preview()


func _on_btn_cabeza_siguiente_pressed() -> void:
	indice_cabeza = _siguiente(indice_cabeza, apariencia.coleccion_cabeza)
	refrescar_preview()

func _on_btn_cabeza_atras_pressed() -> void:
	indice_cabeza = _anterior(indice_cabeza, apariencia.coleccion_cabeza)
	refrescar_preview()


func _on_btn_ojos_siguiente_pressed() -> void:
	indice_ojos = _siguiente(indice_ojos, apariencia.coleccion_ojos)
	refrescar_preview()

func _on_btn_ojos_atras_pressed() -> void:
	indice_ojos = _anterior(indice_ojos, apariencia.coleccion_ojos)
	refrescar_preview()


func _on_btn_nariz_siguiente_pressed() -> void:
	indice_nariz = _siguiente(indice_nariz, apariencia.coleccion_nariz)
	refrescar_preview()

func _on_btn_nariz_atras_pressed() -> void:
	indice_nariz = _anterior(indice_nariz, apariencia.coleccion_nariz)
	refrescar_preview()


func _on_btn_boca_siguiente_pressed() -> void:
	indice_boca = _siguiente(indice_boca, apariencia.coleccion_boca)
	refrescar_preview()

func _on_btn_boca_atras_pressed() -> void:
	indice_boca = _anterior(indice_boca, apariencia.coleccion_boca)
	refrescar_preview()


func _on_btn_cuerpo_siguiente_pressed() -> void:
	indice_cuerpo = _siguiente(indice_cuerpo, apariencia.coleccion_cuerpo)
	refrescar_preview()

func _on_btn_cuerpo_atras_pressed() -> void:
	indice_cuerpo = _anterior(indice_cuerpo, apariencia.coleccion_cuerpo)
	refrescar_preview()


# --------------------------------------------------
# COLOR PICKERS
# --------------------------------------------------

func _on_color_picker_button_cabello_color_changed(color: Color) -> void:
	Global.apariencia.color_cabello = color
	apariencia.restaurar_colores()

func _on_color_picker_button_cabeza_color_changed(color: Color) -> void:
	Global.apariencia.color_cabeza = color
	apariencia.restaurar_colores()

func _on_color_picker_button_ojos_color_changed(color: Color) -> void:
	Global.apariencia.color_ojos = color
	apariencia.restaurar_colores()

func _on_color_picker_button_boca_color_changed(color: Color) -> void:
	Global.apariencia.color_boca = color
	apariencia.restaurar_colores()

func _on_color_picker_button_cuerpo_color_changed(color: Color) -> void:
	Global.apariencia.color_cuerpo = color
	apariencia.restaurar_colores()

# --------------------------------------------------
# BOTÓN FINAL
# --------------------------------------------------

func _on_comenzar_pressed() -> void:
	guardar_en_global()
	get_tree().change_scene_to_file("res://escenas/escena_1/escena_1.tscn")
