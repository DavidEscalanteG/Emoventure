class_name DataManager
extends Node

## Punto único para rutas de datos y futura serialización.

const QUESTIONS_DATA_PATH: String = "res://data/preguntas.json"


func has_questions_data() -> bool:
	return FileAccess.file_exists(QUESTIONS_DATA_PATH)
