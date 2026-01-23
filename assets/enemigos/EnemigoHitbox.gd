extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body == Global.jugador:
		print("☄️ Enemigo golpeó al jugador")
		body.recibir_danio()
