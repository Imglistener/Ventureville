extends CardState

func enter() -> void:
	card_UI.drop_point_detector.monitoring = false
	card_UI.targets.clear()

func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			card_UI.CardClicked.emit(card_UI)
			get_viewport().set_input_as_handled()
