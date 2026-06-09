extends CanvasLayer

const ACTION_MOVE_UP: String = "move_up"
const ACTION_MOVE_DOWN: String = "move_down"
const ACTION_MOVE_LEFT: String = "move_left"
const ACTION_MOVE_RIGHT: String = "move_right"
const ACTION_UI_LEFT: String = "ui_left"
const ACTION_UI_RIGHT: String = "ui_right"

const JOYSTICK_MAX_RADIUS_FACTOR: float = 0.4
const ACTION_STRENGTH_DEADZONE: float = 0.1

@onready var cruceta: Control = $UI/Cruceta
@onready var joystick: Control = $UI/Joystick
@onready var joystick_base: Control = $UI/Joystick/JoystickBase
@onready var joystick_knob: Control = $UI/Joystick/JoystickBase/Knob

var _pressed_actions: Dictionary[String, bool] = {}
var _joy_pointer: int = -1
var _joystick_vector: Vector2 = Vector2.ZERO
var _knob_center: Vector2


func _ready() -> void:
	visible = OS.has_feature("mobile") and MobileControlsSettings.controls_enabled
	set_process(true)
	_knob_center = joystick_knob.position
	_apply_mode()


func _process(_delta: float) -> void:
	if not visible:
		_release_all()
		return
	_apply_mode()


func _apply_mode() -> void:
	var mode: String = MobileControlsSettings.control_mode
	visible = OS.has_feature("mobile") and MobileControlsSettings.controls_enabled
	cruceta.visible = mode == MobileControlsSettings.MODE_CRUCETA
	joystick.visible = mode == MobileControlsSettings.MODE_JOYSTICK
	if mode != MobileControlsSettings.MODE_JOYSTICK:
		_joystick_vector = Vector2.ZERO
		joystick_knob.position = _knob_center
		_apply_axis_to_actions(Vector2.ZERO)


func _on_btn_up_button_down() -> void: _press_action(ACTION_MOVE_UP)
func _on_btn_up_button_up() -> void: _release_action(ACTION_MOVE_UP)
func _on_btn_down_button_down() -> void: _press_action(ACTION_MOVE_DOWN)
func _on_btn_down_button_up() -> void: _release_action(ACTION_MOVE_DOWN)
func _on_btn_left_button_down() -> void: _press_action(ACTION_MOVE_LEFT)
func _on_btn_left_button_up() -> void: _release_action(ACTION_MOVE_LEFT)
func _on_btn_right_button_down() -> void: _press_action(ACTION_MOVE_RIGHT)
func _on_btn_right_button_up() -> void: _release_action(ACTION_MOVE_RIGHT)


func _input(event: InputEvent) -> void:
	if not visible or MobileControlsSettings.control_mode != MobileControlsSettings.MODE_JOYSTICK:
		return
	if event is InputEventScreenTouch:
		if event.pressed and _is_touch_inside_joystick(event.position):
			_joy_pointer = event.index
			_update_joystick(event.position)
		elif not event.pressed and event.index == _joy_pointer:
			_joy_pointer = -1
			_reset_joystick()
	elif event is InputEventScreenDrag and event.index == _joy_pointer:
		_update_joystick(event.position)


func _is_touch_inside_joystick(screen_pos: Vector2) -> bool:
	var rect: Rect2 = Rect2(joystick_base.global_position, joystick_base.size)
	return rect.has_point(screen_pos)


func _update_joystick(screen_pos: Vector2) -> void:
	var center: Vector2 = joystick_base.global_position + (joystick_base.size / 2.0)
	var min_size: float = minf(joystick_base.size.x, joystick_base.size.y)
	var radius: float = min_size * JOYSTICK_MAX_RADIUS_FACTOR
	if radius <= 0.0:
		return

	var delta: Vector2 = screen_pos - center
	if delta.length() > radius:
		delta = delta.normalized() * radius

	_joystick_vector = delta / radius
	joystick_knob.global_position = center + delta - (joystick_knob.size / 2.0)
	_apply_axis_to_actions(_joystick_vector)


func _reset_joystick() -> void:
	_joystick_vector = Vector2.ZERO
	joystick_knob.position = _knob_center
	_apply_axis_to_actions(Vector2.ZERO)


func _apply_axis_to_actions(direction: Vector2) -> void:
	_set_action_strength(ACTION_MOVE_LEFT, maxf(0.0, -direction.x))
	_set_action_strength(ACTION_MOVE_RIGHT, maxf(0.0, direction.x))
	_set_action_strength(ACTION_MOVE_UP, maxf(0.0, -direction.y))
	_set_action_strength(ACTION_MOVE_DOWN, maxf(0.0, direction.y))
	_set_action_strength(ACTION_UI_LEFT, maxf(0.0, -direction.x))
	_set_action_strength(ACTION_UI_RIGHT, maxf(0.0, direction.x))


func _set_action_strength(action: String, strength: float) -> void:
	if strength > ACTION_STRENGTH_DEADZONE:
		Input.action_press(action, strength)
		_pressed_actions[action] = true
	else:
		_release_action(action)


func _press_action(action: String) -> void:
	Input.action_press(action)
	_pressed_actions[action] = true


func _release_action(action: String) -> void:
	if _pressed_actions.has(action):
		Input.action_release(action)
		_pressed_actions.erase(action)


func _release_all() -> void:
	for action: String in _pressed_actions.keys():
		Input.action_release(action)
	_pressed_actions.clear()
