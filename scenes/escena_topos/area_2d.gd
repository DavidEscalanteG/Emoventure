extends Control

func aparecer() -> void:
	show()
	$Timer.start() # El timer empieza SOLO cuando el topo aparece

func _on_timer_timeout() -> void:
	hide() # El timer termina y el topo se guarda
