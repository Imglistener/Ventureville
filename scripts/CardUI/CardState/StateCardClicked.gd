extends CardState

func enter() -> void:
	print("Entering Clicked State...")
	card_UI.sfx.stream = card_UI.clickedSFX
	card_UI.sfx.play()
	card_UI.drop_point_detector.monitoring = true
	
	


		
func on_gui_input(event: InputEvent) -> void:
	print("GUI Input Event intercepted! ", event.as_text())
	if card_UI.card_state_manager.current_state.state != CardState.State.CLICKED:
		print("But the current state is not CLICKED therefore, we are Returning nothing.")
		return
	if event is InputEventMouseMotion:
		print("GUI Event is Mouse Motion, Moving to CardState Draggging.")
		TransitionRequest.emit(self, CardState.State.DRAGGING)
	else:
		print("But for some reason, the event is not identified as MouseMotion...")
