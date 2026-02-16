extends Area2D
var DatosJugador: Object = Engine.get_singleton("DatosJugador") if Engine.has_singleton("DatosJugador") else null
var Logs: Object = Engine.get_singleton("Logs") if Engine.has_singleton("Logs") else null


func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body == DatosJugador.jugador:
		Logs.log_debug("☄️ Enemigo golpeó al jugador")
		body.recibir_danio()
