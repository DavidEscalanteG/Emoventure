extends Node2D

@export var escena_recompensa: String = "res://scenes/recompensa_mision_3/recompensa_mision_3.tscn"
@export var escena_recompensa_legacy: String = ""
@export var golpes_maximos: int = 2

var golpes_recibidos: int = 0
var progreso_actual: int = 0
var _checkpoints_activados: Dictionary = {}
var _bloqueada: bool = false

@onready var jugador: CharacterBody2D = $Jugador
@onready var label_vidas: Label = $CanvasLayer/UI/Panel/VBoxContainer/Vidas
@onready var label_progreso: Label = $CanvasLayer/UI/Panel/VBoxContainer/Progreso
@onready var dano_overlay: ColorRect = $CanvasLayer/DanoOverlay
@onready var sonido_danio: AudioStreamPlayer = $AudioDanio
@onready var salida: Area2D = $Salida

func _ready() -> void:
	jugador.add_to_group("jugador_mision_3")
	jugador.permitir_movimiento()
	jugador.global_position = $SpawnJugador.global_position
	jugador.vidas_actuales = golpes_maximos

	for checkpoint in get_tree().get_nodes_in_group("mision_3_checkpoint"):
		checkpoint.body_entered.connect(_on_checkpoint_body_entered.bind(checkpoint))

	salida.body_entered.connect(_on_salida_body_entered)
	_actualizar_ui()


func registrar_golpe(posicion_hacha: Vector2) -> void:
	if _bloqueada or jugador.invulnerable:
		return

	golpes_recibidos += 1
	jugador.recibir_danio()
	sonido_danio.play()
	_mostrar_flash_danio()

	if golpes_recibidos >= golpes_maximos:
		_bloqueada = true
		jugador.bloquear_movimiento()
		await get_tree().create_timer(0.55).timeout
		get_tree().reload_current_scene()
		return

	var direccion_empuje := (jugador.global_position - posicion_hacha).normalized()
	if direccion_empuje == Vector2.ZERO:
		direccion_empuje = Vector2.RIGHT
	jugador.global_position += direccion_empuje * 36.0
	_actualizar_ui()


func _on_checkpoint_body_entered(body: Node, checkpoint: Area2D) -> void:
	if _bloqueada or not body.is_in_group("jugador_mision_3"):
		return
	if _checkpoints_activados.has(checkpoint.name):
		return

	_checkpoints_activados[checkpoint.name] = true
	progreso_actual += 1
	var sprite: Sprite2D = checkpoint.get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color(0.5, 1.0, 0.5, 1.0)
	_actualizar_ui()


func _on_salida_body_entered(body: Node) -> void:
	if _bloqueada or not body.is_in_group("jugador_mision_3"):
		return
	if progreso_actual < 2:
		return

	_bloqueada = true
	jugador.bloquear_movimiento()
	await get_tree().create_timer(0.35).timeout
	var destino := escena_recompensa if not escena_recompensa.is_empty() else escena_recompensa_legacy
	if destino.is_empty():
		push_warning("No se configuró la escena de recompensa de misión 3")
		return
	get_tree().change_scene_to_file(destino)


func _mostrar_flash_danio() -> void:
	dano_overlay.modulate = Color(1, 0.15, 0.15, 0.45)
	var tween := create_tween()
	tween.tween_property(dano_overlay, "modulate:a", 0.0, 0.35)


func _actualizar_ui() -> void:
	var vidas_restantes: int = max(golpes_maximos - golpes_recibidos, 0)
	label_vidas.text = "Vidas: %d/%d" % [vidas_restantes, golpes_maximos]
	label_progreso.text = "Progreso: %d/2 palancas" % progreso_actual