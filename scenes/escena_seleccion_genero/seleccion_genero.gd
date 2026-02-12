extends Control

@onready var jugador_hombre = $VBoxContainer/HBoxContainer/ContenedorHombre/JugadorHombre
@onready var jugador_mujer = $VBoxContainer/HBoxContainer/ContenedorMujer/JugadorMujer

func _ready():
	_configurar_previews()


func _configurar_previews():
	jugador_hombre.forzar_indice_cabello = DatosJugador.obtener_indice_cabello_inicio(DatosJugador.GENERO_HOMBRE)
	jugador_mujer.forzar_indice_cabello = DatosJugador.obtener_indice_cabello_inicio(DatosJugador.GENERO_MUJER)
	
	jugador_hombre.refrescar_preview()
	jugador_mujer.refrescar_preview()


func _on_boton_hombre_pressed():
	DatosJugador.set_genero(DatosJugador.GENERO_HOMBRE)
	_asignar_indices_base()
	get_tree().change_scene_to_file("uid://cxv23v4515m48")



func _on_boton_mujer_pressed():
	DatosJugador.set_genero(DatosJugador.GENERO_MUJER)
	_asignar_indices_base()
	get_tree().change_scene_to_file("uid://cxv23v4515m48")

func _asignar_indices_base():
	DatosJugador.set_indice_cabello(DatosJugador.obtener_indice_cabello_inicio())
	DatosJugador.reiniciar_indices_apariencia()
