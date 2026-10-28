extends Control

func _ready() -> void:
	InteractiveButtonFX.aplicar_a_botones_en(self)
	
func _on_btn_jugar_pressed() -> void:
	# Esta es la línea que desbloquea el sonido en web:
	if OS.has_feature("web"):
		MusicManager.iniciar_musica_web()
		
	# Continúa con tu código normal para cambiar de escena
	get_tree().change_scene_to_file("res://scenes/tu_siguiente_escena.tscn")
