extends Control
var DatosJugador: Object = Engine.get_singleton("DatosJugador") if Engine.has_singleton("DatosJugador") else ((Engine.get_main_loop().root.get_node_or_null("DatosJugador")) if Engine.get_main_loop() is SceneTree else null)
var GameManager: Object = Engine.get_singleton("GameManager") if Engine.has_singleton("GameManager") else ((Engine.get_main_loop().root.get_node_or_null("GameManager")) if Engine.get_main_loop() is SceneTree else null)


const MENU_PRINCIPAL_SCENE: String = "res://scenes/menu_principal/menu_principal.tscn"
const DIMENSIONES: Array[String] = ["atencion", "claridad", "reparacion"]
const NOMBRES_DIMENSION: Dictionary[String, String] = {
	"atencion": "Atención emocional",
	"claridad": "Claridad emocional",
	"reparacion": "Reparación emocional"
}

const GENERO_HOMBRE: String = "hombre"
const GENERO_MUJER: String = "mujer"

const UMBRALES_MENSAJES_POR_GENERO: Dictionary[String, Dictionary] = {
	GENERO_HOMBRE: {
		"atencion": {
			"bajo_max": 21,
			"medio_max": 32,
			"mensajes": {
				"bajo": "Debe mejorar su atención: presta poca atención.",
				"medio": "Adecuada atención.",
				"alto": "Debe mejorar su atención: presta demasiada atención."
			}
		},
		"claridad": {
			"bajo_max": 25,
			"medio_max": 35,
			"mensajes": {
				"bajo": "Debe mejorar su claridad emocional.",
				"medio": "Adecuada claridad emocional.",
				"alto": "Excelente claridad emocional."
			}
		},
		"reparacion": {
			"bajo_max": 23,
			"medio_max": 35,
			"mensajes": {
				"bajo": "Debe mejorar su reparación de las emociones.",
				"medio": "Adecuada reparación de las emociones.",
				"alto": "Excelente reparación de las emociones."
			}
		}
	},
	GENERO_MUJER: {
		"atencion": {
			"bajo_max": 24,
			"medio_max": 35,
			"mensajes": {
				"bajo": "Debe mejorar su atención: presta poca atención.",
				"medio": "Adecuada atención.",
				"alto": "Debe mejorar su atención: presta demasiada atención."
			}
		},
		"claridad": {
			"bajo_max": 23,
			"medio_max": 34,
			"mensajes": {
				"bajo": "Debe mejorar su claridad emocional.",
				"medio": "Adecuada claridad emocional.",
				"alto": "Excelente claridad emocional."
			}
		},
		"reparacion": {
			"bajo_max": 23,
			"medio_max": 34,
			"mensajes": {
				"bajo": "Debe mejorar su reparación de las emociones.",
				"medio": "Adecuada reparación de las emociones.",
				"alto": "Excelente reparación de las emociones."
			}
		}
	}
}

@onready var label_narrativa: Label = %NarrativaLabel
@onready var tarjetas_container: VBoxContainer = %TarjetasContainer
@onready var label_perfil_final: Label = %PerfilFinalLabel
@onready var boton_menu_principal: Button = %BotonMenuPrincipal

@onready var titulo_atencion: Label = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaAtencion/Margen/VBox/TituloAtencion"
@onready var barra_atencion: ProgressBar = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaAtencion/Margen/VBox/BarraAtencion"
@onready var mensaje_atencion: Label = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaAtencion/Margen/VBox/MensajeAtencion"

@onready var titulo_claridad: Label = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaClaridad/Margen/VBox/TituloClaridad"
@onready var barra_claridad: ProgressBar = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaClaridad/Margen/VBox/BarraClaridad"
@onready var mensaje_claridad: Label = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaClaridad/Margen/VBox/MensajeClaridad"

@onready var titulo_reparacion: Label = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaReparacion/Margen/VBox/TituloReparacion"
@onready var barra_reparacion: ProgressBar = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaReparacion/Margen/VBox/BarraReparacion"
@onready var mensaje_reparacion: Label = $"MarginContainer/VBoxPrincipal/TarjetasContainer/TarjetaReparacion/Margen/VBox/MensajeReparacion"


func _ready() -> void:
	label_narrativa.text = "Ahora te revelaré quién eres"
	_renderizar_resumen()
	boton_menu_principal.pressed.connect(_on_boton_menu_principal_pressed)


func _renderizar_resumen() -> void:
	var puntajes: Dictionary[String, int] = GameManager.obtener_puntajes_por_dimension()
	var total_global: int = 0
	for dimension in DIMENSIONES:
		total_global += puntajes.get(dimension, 0)

	_actualizar_tarjeta_dimension("atencion", puntajes.get("atencion", 0), titulo_atencion, barra_atencion, mensaje_atencion)
	_actualizar_tarjeta_dimension("claridad", puntajes.get("claridad", 0), titulo_claridad, barra_claridad, mensaje_claridad)
	_actualizar_tarjeta_dimension("reparacion", puntajes.get("reparacion", 0), titulo_reparacion, barra_reparacion, mensaje_reparacion)

	label_perfil_final.text = _construir_texto_perfil_final(puntajes, total_global)


func _actualizar_tarjeta_dimension(dimension: String, puntaje: int, titulo: Label, barra: ProgressBar, mensaje: Label) -> void:
	titulo.text = "%s · %d/40" % [NOMBRES_DIMENSION.get(dimension, dimension.capitalize()), puntaje]
	barra.min_value = 0
	barra.max_value = 40
	barra.value = puntaje
	mensaje.text = _obtener_mensaje_dimension(dimension, puntaje)


func _obtener_mensaje_dimension(dimension: String, puntaje: int) -> String:
	var umbrales_genero: Dictionary = _obtener_umbrales_genero()
	var config: Dictionary = umbrales_genero.get(dimension, {})
	if config.is_empty():
		return "Sin configuración de mensaje para esta dimensión."

	var mensajes: Dictionary = config.get("mensajes", {})
	if puntaje <= int(config.get("bajo_max", 16)):
		return mensajes.get("bajo", "")
	if puntaje <= int(config.get("medio_max", 28)):
		return mensajes.get("medio", "")
	return mensajes.get("alto", "")


func _obtener_umbrales_genero() -> Dictionary:
	var genero: String = str(DatosJugador.genero).to_lower().strip_edges()
	if not UMBRALES_MENSAJES_POR_GENERO.has(genero):
		genero = GENERO_HOMBRE
	return UMBRALES_MENSAJES_POR_GENERO.get(genero, {})


func _construir_texto_perfil_final(puntajes: Dictionary[String, int], total_global: int) -> String:
	var dimension_dominante: String = ""
	var puntaje_mayor: int = -1

	for dimension in DIMENSIONES:
		var actual: int = puntajes.get(dimension, 0)
		if actual > puntaje_mayor:
			puntaje_mayor = actual
			dimension_dominante = dimension

	var etiqueta_dominante: String = NOMBRES_DIMENSION.get(dimension_dominante, "tu dimensión principal")
	return "Tu energía emocional dominante está en %s. Puntaje total acumulado: %d puntos.\n\nSigue explorando, porque cada emoción comprendida te vuelve más fuerte." % [etiqueta_dominante, total_global]


func _on_boton_menu_principal_pressed() -> void:
	# Cierre completo del ciclo: limpia puntajes y estado temporal antes de volver al menú.
	GameManager.reiniciar_puntajes()
	if DatosJugador.has_method("reiniciar_estado_temporal"):
		DatosJugador.reiniciar_estado_temporal()
	get_tree().change_scene_to_file(MENU_PRINCIPAL_SCENE)
