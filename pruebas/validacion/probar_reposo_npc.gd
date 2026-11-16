extends SceneTree

const AnimationService = preload("res://src/autoload/servicios/dialogue_actor_animation_service.gd")
const MovementService = preload("res://src/autoload/servicios/dialogue_actor_movement_service.gd")

class RecordingAnimationService extends AnimationService:
	var warnings: Array[String] = []
	func warn(actor_id: String, actor: Node, message: String) -> void:
		warnings.append(message + " " + actor_debug_name(actor_id, actor))

var checks := 0
var failures := 0
var animations := RecordingAnimationService.new()
var movement := MovementService.new(animations)

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func test_actor(actor: Node2D, actor_id: String, moving_animation: String, expected_idle: String) -> void:
	root.add_child(actor)
	var sprite: AnimatedSprite2D = actor.get_node("AnimatedSprite2D")
	sprite.play(moving_animation)
	var origin := actor.global_position
	var warnings_before := animations.warnings.size()
	await movement.mover_y_esperar(actor_id, actor, Vector2(100, 0), 0.02)
	check(actor.global_position.is_equal_approx(origin + Vector2(100, 0)), actor_id + ": completa el desplazamiento")
	check(sprite.animation == expected_idle, actor_id + ": pasa a " + expected_idle)
	check(animations.warnings.size() == warnings_before, actor_id + ": el reposo válido no genera advertencias")
	check(sprite.sprite_frames.has_animation(expected_idle) and sprite.sprite_frames.get_frame_count(expected_idle) > 0, actor_id + ": el reposo tiene fotogramas reales")
	actor.queue_free()
	await process_frame

func run() -> void:
	for side: String in ["derecha", "izquierda"]:
		var clown: Node2D = load("res://assets/personajes/payaso/payaso.tscn").instantiate()
		await test_actor(clown, "payaso", "equilibrio_" + side, "idle_" + side)
	# Los dos desplazamientos de Fran en la escena de rescate deben terminar
	# en su postura neutra antes de que el diálogo ordene el golpe siguiente.
	for index in range(2):
		var fran: Node2D = load("res://assets/personajes/fran/fran.tscn").instantiate()
		await test_actor(fran, "fran", "caminar_derecha", "default")
	# La primera aparición de Fran usa un SpriteFrames local de la escena.
	var scene: Node = load("res://scenes/intro_dialogo_9/intro_dialogo_9.tscn").instantiate()
	var original: Node2D = scene.get_node("personajes/Fran")
	scene.get_node("personajes").remove_child(original)
	scene.free()
	await test_actor(original, "fran", "default_down", "default_down")
	# Un actor realmente incompleto debe seguir produciendo un diagnóstico.
	var incomplete := Node2D.new()
	var sprite := AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.sprite_frames = SpriteFrames.new()
	incomplete.add_child(sprite)
	root.add_child(incomplete)
	var warnings_before := animations.warnings.size()
	animations.establecer_idle("incompleto", incomplete)
	check(animations.warnings.size() == warnings_before + 1, "La validación de animaciones faltantes se conserva")
	incomplete.queue_free()
	await process_frame
	print("REPOSO_NPC: %d comprobaciones, %d fallos, %d advertencias inesperadas, %d detectadas en el control negativo" % [checks, failures, warnings_before, animations.warnings.size() - warnings_before])
	quit(0 if failures == 0 else 1)
