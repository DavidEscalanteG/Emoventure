extends Area2D

signal fuego_extinguido(interseccion: Node2D)

@export var tiempo_activo: float = 2.4
@export var tiempo_parpadeo_final: float = 0.8
@export var intervalo_parpadeo: float = 0.1

var interseccion: Node2D = null
var _desactivado: bool = false
var _ciclo_vida: Tween

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var colision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	sprite.play("start")
	sprite.animation_finished.connect(_on_animacion_terminada)

	_iniciar_ciclo_vida()


func configurar_interseccion(nueva_interseccion: Node2D) -> void:
	interseccion = nueva_interseccion


func bloquear_movimiento() -> void:
	if _desactivado:
		return
	_desactivado = true
	colision.set_deferred("disabled", true)
	if _ciclo_vida != null:
		_ciclo_vida.kill()
	sprite.stop()


func _iniciar_ciclo_vida() -> void:
	_ciclo_vida = create_tween()
	_ciclo_vida.tween_interval(tiempo_activo)
	var intervalo := maxf(intervalo_parpadeo, 0.01)
	var restante := tiempo_parpadeo_final
	while restante > 0.0:
		_ciclo_vida.tween_callback(func(): sprite.visible = not sprite.visible)
		_ciclo_vida.tween_interval(minf(intervalo, restante))
		restante -= intervalo
	_ciclo_vida.tween_callback(_terminar_ciclo)


func _terminar_ciclo() -> void:
	if _desactivado:
		return
	colision.set_deferred("disabled", true)
	sprite.visible = true
	sprite.play("end")


func _on_animacion_terminada() -> void:
	if sprite.animation == "start":
		sprite.play("loop")
	elif sprite.animation == "end":
		_emitir_extincion_y_liberar()


func _on_body_entered(body: Node) -> void:
	if _desactivado:
		return
	if body == DatosJugador.jugador:
		body.recibir_danio()


func _emitir_extincion_y_liberar() -> void:
	if _desactivado:
		return
	_desactivado = true
	fuego_extinguido.emit(interseccion)
	queue_free()
