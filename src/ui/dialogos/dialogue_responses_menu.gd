extends DialogueResponsesMenu
## En móvil, BaseButton distingue una pulsación de un arrastre dentro del
## ScrollContainer. El menú del complemento elige al presionar, demasiado pronto.

var select_on_release := false

func configure_focus() -> void:
	super.configure_focus()
	if not select_on_release:
		return
	for item: Button in get_menu_items():
		item.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		item.pressed.connect(_select_response.bind(item.get_meta("response")))

func _on_response_gui_input(event: InputEvent, item: Control, response) -> void:
	if not select_on_release:
		super._on_response_gui_input(event, item, response)

func _on_response_mouse_entered(item: Control) -> void:
	if not select_on_release:
		super._on_response_mouse_entered(item)

func _select_response(response: Variant) -> void:
	response_selected.emit(response)
