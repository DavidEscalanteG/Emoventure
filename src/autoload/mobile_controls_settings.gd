extends Node

const SETTINGS_PATH := "user://mobile_controls.cfg"

const MODE_CRUCETA := "cruceta"
const MODE_JOYSTICK := "joystick"
const MODE_OFF := "off"

var controls_enabled: bool = true
var control_mode: String = MODE_CRUCETA

func _ready() -> void:
	_load_settings()


func set_controls_enabled(enabled: bool) -> void:
	controls_enabled = enabled
	_save_settings()


func set_control_mode(mode: String) -> void:
	if mode not in [MODE_CRUCETA, MODE_JOYSTICK, MODE_OFF]:
		return
	control_mode = mode
	controls_enabled = mode != MODE_OFF
	_save_settings()


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("mobile_controls", "enabled", controls_enabled)
	config.set_value("mobile_controls", "mode", control_mode)
	config.save(SETTINGS_PATH)


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	controls_enabled = bool(config.get_value("mobile_controls", "enabled", true))
	control_mode = String(config.get_value("mobile_controls", "mode", MODE_CRUCETA))
	if control_mode == MODE_OFF:
		controls_enabled = false
