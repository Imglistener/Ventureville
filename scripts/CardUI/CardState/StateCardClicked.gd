extends CardState
## Card was pressed. Capture state: uses on_input only.
##
## Movement starts the drag whether or not the button is still held, so both
## "press, drag, release" and "click to pick up, move, click to drop" work.
## Right-click cancels.

func uses_global_input() -> bool:
	return true


func enter() -> void:
	card_UI.z_index = 100
	card_UI.sfx.stream = card_UI.clickedSFX
	card_UI.sfx.play()
	card_UI.drop_point_detector.monitoring = true


func on_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		request_transition(State.DRAGGING)
	elif event.is_action_pressed("mouse_right"):
		request_transition(State.IDLING)
