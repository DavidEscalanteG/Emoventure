extends Node2D

const DIALOGO_ESCENA_7 := preload("uid://b5t1y0j0xbtoe") #escena_7.dialogue")
const SIGUIENTE_ESCENA := "uid://607ynm435j8g" #escena_8.tcsn

@onready var dialogue_ui: Node = $DialogueUI/Balloon
@onready var panel_nombre_mascota: Control = $UI/PanelNombreMascota
@onready var input_nombre_mascota: LineEdit = $UI/PanelNombreMascota/MarginContainer/VBoxContainer/InputNombreMascota
@onready var error_nombre_mascota: Label = $UI/PanelNombreMascota/MarginContainer/VBoxContainer/ErrorNombreMascota

func _ready() -> void:
	MusicManager.iniciar_override_dialogo(MusicManager.AMBIENTE_TENSION)
	_inicializar_nombre_mascota()
	panel_nombre_mascota.visible = false
	
	DialogueActors.registro_registrar_actor("jugador", $Personajes/JugadorCinematico)
	DialogueActors.registro_registrar_actor("mascota", $Personajes/Mascota)
	dialogue_ui.dialogo_finalizado.connect(_on_dialogo_finalizado)
	
	#await get_tree().create_timer(1.0).timeout
	dialogue_ui.iniciar_dialogo(DIALOGO_ESCENA_7)
	

func _on_dialogo_finalizado() -> void:
	panel_nombre_mascota.visible = true
	input_nombre_mascota.grab_focus()


func _exit_tree() -> void:
	DialogueActors.reiniciar_estado_cinematica()
	DialogueActors.registro_desregistrar_actor("jugador")
	DialogueActors.registro_desregistrar_actor("mascota")
	MusicManager.finalizar_override_dialogo()


func _on_btn_confirmar_nombre_mascota_pressed() -> void:
	AudioManager.play_ui_click()
	var validacion := DatosJugador.validar_nombre(input_nombre_mascota.text)
	if not validacion.ok:
		error_nombre_mascota.text = validacion.mensaje
		return

	DatosJugador.nombre_mascota = validacion.nombre
	error_nombre_mascota.text = ""
	MusicManager.finalizar_override_dialogo()
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)


func _inicializar_nombre_mascota() -> void:
	if DatosJugador.nombre_mascota.is_empty():
		DatosJugador.nombre_mascota = DatosJugador.NOMBRE_MASCOTA_PREDETERMINADO
	input_nombre_mascota.text = DatosJugador.nombre_mascota
	error_nombre_mascota.text = ""
