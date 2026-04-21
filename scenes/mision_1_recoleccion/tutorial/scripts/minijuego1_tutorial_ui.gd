extends CanvasLayer
class_name Minijuego1TutorialUI

signal previous_pressed
signal next_pressed
signal skip_pressed
signal start_pressed

@onready var message_label: Label = $Overlay/BottomPanel/MarginContainer/VBoxContainer/MessageLabel
@onready var previous_button: Button = $Overlay/BottomPanel/MarginContainer/VBoxContainer/NavigationRow/PreviousButton
@onready var next_button: Button = $Overlay/BottomPanel/MarginContainer/VBoxContainer/NavigationRow/NextButton
@onready var skip_button: Button = $Overlay/TopBar/SkipButton
@onready var start_button: Button = $Overlay/BottomPanel/MarginContainer/VBoxContainer/NavigationRow/StartButton
@onready var key_map := {
	"W": $Overlay/BottomPanel/MarginContainer/VBoxContainer/KeysRow/WKey,
	"A": $Overlay/BottomPanel/MarginContainer/VBoxContainer/KeysRow/AKey,
	"S": $Overlay/BottomPanel/MarginContainer/VBoxContainer/KeysRow/SKey,
	"D": $Overlay/BottomPanel/MarginContainer/VBoxContainer/KeysRow/DKey,
}

func _ready() -> void:
	InteractiveButtonFX.aplicar_a_botones_en(self)
	previous_button.pressed.connect(func() -> void: previous_pressed.emit())
	next_button.pressed.connect(func() -> void: next_pressed.emit())
	skip_button.pressed.connect(func() -> void: skip_pressed.emit())
	start_button.pressed.connect(func() -> void: start_pressed.emit())
	reset_keys()

func set_message(text: String) -> void:
	message_label.text = text

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

func show_keys(is_visible: bool) -> void:
	$Overlay/BottomPanel/MarginContainer/VBoxContainer/KeysRow.visible = is_visible
	if not is_visible:
		reset_keys()

func animate_key(key_name: String) -> void:
	for key in key_map.keys():
		(key_map[key] as KeyVisual).set_active(key == key_name)

func reset_keys() -> void:
	for key in key_map.values():
		(key as KeyVisual).set_active(false)
