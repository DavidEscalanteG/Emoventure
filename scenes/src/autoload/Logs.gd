extends Node

const DEBUG_LOGS: bool = false

var qa_debug_logs: bool = false

func set_debug_logs(enabled: bool) -> void:
	qa_debug_logs = enabled

func is_debug_enabled() -> bool:
	return DEBUG_LOGS or qa_debug_logs

func log_debug(message: Variant) -> void:
	if is_debug_enabled():
		print(message)
