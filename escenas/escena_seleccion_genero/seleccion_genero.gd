extends Control

@onready var jugador_hombre = $VBoxContainer/HBoxContainer/ContenedorHombre/JugadorHombre
@onready var jugador_mujer = $VBoxContainer/HBoxContainer/ContenedorMujer/JugadorMujer

func _ready():
	_configurar_previews()


func _configurar_previews():
	# Hombre usa primer rango
	jugador_hombre.forzar_indice_cabello = 1
	
	# Mujer usa primer índice femenino (16)
	jugador_mujer.forzar_indice_cabello = 18
	
	jugador_hombre._ready()
	jugador_mujer._ready()


func _on_boton_hombre_pressed():
	Global.genero = "hombre"
	_asignar_indices_base()
	get_tree().change_scene_to_file("uid://cxv23v4515m48")



func _on_boton_mujer_pressed():
	Global.genero = "mujer"
	_asignar_indices_base()
	get_tree().change_scene_to_file("uid://cxv23v4515m48")

func _asignar_indices_base():
	if Global.genero == "hombre":
		Global.apariencia.indice_cabello = 1
	elif Global.genero == "mujer":
		Global.apariencia.indice_cabello = 16
	
	# Reiniciar otros índices si quieres
	Global.apariencia.indice_cabeza = 0
	Global.apariencia.indice_ojos = 0
	Global.apariencia.indice_boca = 0
	Global.apariencia.indice_cuerpo = 0
	Global.apariencia.indice_nariz = 0
