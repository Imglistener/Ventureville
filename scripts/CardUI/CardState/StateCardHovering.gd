extends CardState

const	 MOUSE_Y_SNAPBACKTHRESHOLD := 650


func enter() -> void:
	card_UI.targets.clear()
	card_UI.sfx.stream = card_UI.aimingSFX
	card_UI.sfx.play()
	card_UI.card_targeting = true
	var offset := Vector2(get_viewport().size.x/2, -card_UI.size.y/ 2)
	offset.x -= card_UI.size.x / 2
	card_UI.animate_to_position(card_UI.parent.position + Vector2(300, -150), 0.2)
	card_UI.z_index = 100                        # consistent with hover z
	card_UI.drop_point_detector.monitoring = false
	Events.card_aim_started.emit(card_UI)
	
func exit() -> void:
	card_UI.z_index = card_UI.get_index()        # restore to hand stack position
	Events.card_aim_finished.emit(card_UI)
	card_UI.card_targeting = false
	card_UI.sfx.stop()
func on_input(event: InputEvent) -> void:
	var mouse_motion := event is InputEventMouseMotion
	var mouse_at_bottom := card_UI.get_global_mouse_position().y > MOUSE_Y_SNAPBACKTHRESHOLD
	if mouse_at_bottom and mouse_motion or event.is_action_pressed("mouse_right"):
		TransitionRequest.emit(self, CardState.State.IDLING)
	elif event.is_action_released("mouse_left") or event.is_action_pressed("mouse_left"):
		get_viewport().set_input_as_handled()
		TransitionRequest.emit(self, CardState.State.RELEASED)
