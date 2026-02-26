class_name LogManager
extends Node

const DEBUG_LOGS: bool = false

var qa_debug_logs: bool = false


func set_debug_logs(enabled: bool) -> void:
	qa_debug_logs = enabled


func is_debug_enabled() -> bool:
	return DEBUG_LOGS or qa_debug_logs


func log_debug(context: String, message: Variant) -> void:
	if is_debug_enabled():
		print(_format_message("DEBUG", context, message))


func log_info(context: String, message: Variant) -> void:
	print(_format_message("INFO", context, message))


func log_warning(context: String, message: Variant) -> void:
	push_warning(_format_message("WARN", context, message))


func log_error(context: String, message: Variant) -> void:
	push_error(_format_message("ERROR", context, message))


func _format_message(level: String, context: String, message: Variant) -> String:
	return "[%s][%s] %s" % [level, context, str(message)]
