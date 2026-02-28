extends Area2D

signal fuego_extinguido(interseccion: Node2D)

@export var tiempo_activo: float = 2.4
@export var tiempo_parpadeo_final: float = 0.8
@export var intervalo_parpadeo: float = 0.1

var interseccion: Node2D = null
var _desactivado: bool = false

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
	colision.disabled = true
	sprite.stop()


func _iniciar_ciclo_vida() -> void:
	await get_tree().create_timer(tiempo_activo).timeout
	if _desactivado:
		return

	await _parpadear(tiempo_parpadeo_final)
	if _desactivado:
		return

	colision.disabled = true
	sprite.play("end")
	await sprite.animation_finished
	_emitir_extincion_y_liberar()


func _parpadear(duracion: float) -> void:
	var tiempo_transcurrido: float = 0.0
	while tiempo_transcurrido < duracion and not _desactivado:
		sprite.visible = not sprite.visible
		await get_tree().create_timer(intervalo_parpadeo).timeout
		tiempo_transcurrido += intervalo_parpadeo
	sprite.visible = true


func _on_animacion_terminada() -> void:
	if sprite.animation == "start":
		sprite.play("loop")


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
