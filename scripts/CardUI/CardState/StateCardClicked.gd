extends CardState

func enter() -> void:
	card_UI.sfx.stream = card_UI.clickedSFX
	card_UI.sfx.play()
	card_UI.drop_point_detector.monitoring = true
	
	

func on_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		TransitionRequest.emit(self, CardState.State.DRAGGING)
		
