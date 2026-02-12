extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body == Global.jugador:
		Logs.log_debug("☄️ Enemigo golpeó al jugador")
		body.recibir_danio()
