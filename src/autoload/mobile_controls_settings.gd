extends Node

signal settings_changed

const SETTINGS_PATH := "user://mobile_controls.cfg"

const MODE_CRUCETA := "cruceta"
const MODE_JOYSTICK := "joystick"
const MODE_OFF := "off"
const TOUCH_MODES: Array[String] = [MODE_CRUCETA, MODE_JOYSTICK]
const CUSTOM_KEY_ACTIONS: Array[String] = ["move_up", "move_down", "move_left", "move_right"]
const REQUIRED_KEYS: Dictionary = {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
}

var controls_enabled: bool = true
var control_mode: String = MODE_CRUCETA
var custom_keys: Dictionary[String, Key] = {}

func _ready() -> void:
	_load_settings()


func set_controls_enabled(_enabled: bool) -> void:
	# En móviles siempre debe existir una forma de control táctil. En escritorio
	# la decisión es automática y no depende de una preferencia guardada.
	if is_mobile_device():
		controls_enabled = true
		if control_mode not in TOUCH_MODES:
			control_mode = MODE_CRUCETA
	else:
		controls_enabled = false
		control_mode = MODE_OFF
	_save_settings()
	settings_changed.emit()


func set_control_mode(mode: String) -> void:
	if not is_mobile_device():
		control_mode = MODE_OFF
		controls_enabled = false
		settings_changed.emit()
		return
	if mode not in TOUCH_MODES:
		return
	control_mode = mode
	controls_enabled = true
	_save_settings()
	settings_changed.emit()


func should_show_touch_controls() -> bool:
	return controls_enabled and is_mobile_device() and control_mode in TOUCH_MODES


func is_touch_device() -> bool:
	return is_mobile_device()


func is_mobile_device() -> bool:
	# No se usa DisplayServer.is_touchscreen_available(): también es verdadero
	# en laptops Windows con pantalla táctil, donde la UI móvil debe permanecer
	# desactivada. Las etiquetas nativas cubren Android/iOS.
	if OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("mobile"):
		return true
	if OS.has_feature("web"):
		var mobile_web: Variant = JavaScriptBridge.eval(
			"/Android|iPhone|iPad|iPod|Mobile/i.test(navigator.userAgent) || " \
			+ "(navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1)",
			true
		)
		return bool(mobile_web)
	return false


func set_custom_key(action: String, physical_keycode: Key) -> void:
	if action not in CUSTOM_KEY_ACTIONS or physical_keycode == KEY_NONE:
		return
	_remove_custom_key_event(action)
	custom_keys.erase(action)
	# WASD y flechas son enlaces protegidos: elegir uno de ellos equivale a no
	# necesitar una tecla adicional y nunca debe borrar el enlace base.
	if physical_keycode in REQUIRED_KEYS[action]:
		_save_settings()
		return
	for other_action: String in CUSTOM_KEY_ACTIONS:
		if other_action != action and custom_keys.get(other_action, KEY_NONE) == physical_keycode:
			_remove_custom_key_event(other_action)
			custom_keys.erase(other_action)
	var event := InputEventKey.new()
	event.physical_keycode = physical_keycode
	InputMap.action_add_event(action, event)
	custom_keys[action] = physical_keycode
	_save_settings()


func clear_custom_keys() -> void:
	for action: String in CUSTOM_KEY_ACTIONS:
		_remove_custom_key_event(action)
	custom_keys.clear()
	_save_settings()


func get_custom_key_text(action: String) -> String:
	if not custom_keys.has(action):
		return "Agregar tecla"
	var event := InputEventKey.new()
	event.physical_keycode = custom_keys[action]
	return event.as_text_physical_keycode()


func _remove_custom_key_event(action: String) -> void:
	if not custom_keys.has(action):
		return
	var old_key: Key = custom_keys[action]
	if old_key in REQUIRED_KEYS[action]:
		return
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == old_key:
			InputMap.action_erase_event(action, event)


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("mobile_controls", "enabled", true)
	# MODE_OFF es un estado automático de escritorio, no una preferencia. Así
	# no se pierde la elección táctil al usar el mismo perfil en otra plataforma.
	if control_mode in TOUCH_MODES:
		config.set_value("mobile_controls", "mode", control_mode)
	else:
		config.set_value("mobile_controls", "mode", MODE_CRUCETA)
	for action: String in CUSTOM_KEY_ACTIONS:
		if custom_keys.has(action):
			config.set_value("keyboard", action, int(custom_keys[action]))
		elif config.has_section_key("keyboard", action):
			config.erase_section_key("keyboard", action)
	config.save(SETTINGS_PATH)


func _load_settings() -> void:
	var config := ConfigFile.new()
	var saved_mode: String = MODE_CRUCETA
	if config.load(SETTINGS_PATH) == OK:
		saved_mode = String(config.get_value("mobile_controls", "mode", MODE_CRUCETA))
		_load_custom_keys(config)
	if saved_mode not in TOUCH_MODES:
		saved_mode = MODE_CRUCETA
	if is_mobile_device():
		control_mode = saved_mode
		controls_enabled = true
	else:
		control_mode = MODE_OFF
		controls_enabled = false


func _load_custom_keys(config: ConfigFile) -> void:
	custom_keys.clear()
	for action: String in CUSTOM_KEY_ACTIONS:
		var keycode: Key = int(config.get_value("keyboard", action, KEY_NONE)) as Key
		if keycode == KEY_NONE:
			continue
		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_add_event(action, event)
		custom_keys[action] = keycode
