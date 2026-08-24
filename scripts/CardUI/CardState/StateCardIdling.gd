extends CardState

func enter() -> void:
	card_UI.drop_point_detector.monitoring = false
	card_UI.targets.clear()
	if not card_UI.is_node_ready():
		await card_UI.ready
	if card_UI.tween and card_UI.tween.is_running():
		card_UI.tween.kill()
	card_UI.ReparentRequest.emit(card_UI)
	card_UI.animate_to_hand()
	
func on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		card_UI.drag_offset = card_UI.get_global_mouse_position() - card_UI.global_position
		TransitionRequest.emit(self, CardState.State.CLICKED)
