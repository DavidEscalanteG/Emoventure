extends CanvasLayer
class_name Minijuego2TutorialUI

signal previous_pressed
signal next_pressed
signal start_pressed
signal skip_pressed

@onready var dark_overlay: ColorRect = $Overlay/DarkOverlay
@onready var message_label: Label = $Overlay/BottomPanel/MarginContainer/VBoxContainer/MessageLabel
@onready var step_label: Label = $Overlay/BottomPanel/MarginContainer/VBoxContainer/StepLabel
@onready var previous_button: Button = $Overlay/BottomPanel/MarginContainer/VBoxContainer/NavigationRow/PreviousButton
@onready var next_button: Button = $Overlay/BottomPanel/MarginContainer/VBoxContainer/NavigationRow/NextButton
@onready var start_button: Button = $Overlay/BottomPanel/MarginContainer/VBoxContainer/NavigationRow/StartButton
@onready var skip_button: Button = $Overlay/TopBar/SkipButton

func _ready() -> void:
	InteractiveButtonFX.aplicar_a_botones_en(self)
	previous_button.pressed.connect(func() -> void: previous_pressed.emit())
	next_button.pressed.connect(func() -> void: next_pressed.emit())
	start_button.pressed.connect(func() -> void: start_pressed.emit())
	skip_button.pressed.connect(func() -> void: skip_pressed.emit())

func set_message(text: String) -> void:
	message_label.text = text

func set_step_indicator(current_step: int, total_steps: int) -> void:
	step_label.text = "Paso %d de %d" % [current_step + 1, total_steps]

func set_navigation(step_index: int, _step_count: int, is_last_step: bool) -> void:
	previous_button.disabled = step_index <= 0
	next_button.visible = not is_last_step
	start_button.visible = is_last_step
	if is_last_step:
		start_button.disabled = false
	next_button.disabled = false

func set_continue_enabled(is_enabled: bool) -> void:
	if next_button.visible:
		next_button.disabled = not is_enabled

func set_overlay_alpha(alpha: float) -> void:
	dark_overlay.color = Color(0, 0, 0, clampf(alpha, 0.0, 1.0))
