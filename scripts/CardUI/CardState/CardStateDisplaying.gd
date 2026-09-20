extends CardState
## Card shown in the deck viewer. Hover state: uses on_gui_input only.

func enter() -> void:
	card_UI.drop_point_detector.monitoring = false
	card_UI.targets.clear()


func on_gui_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		card_UI.CardClicked.emit(card_UI)
		card_UI.accept_event()
