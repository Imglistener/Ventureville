extends CardState

const TILT_FACTOR := 0.04        # how aggressively it tilts per pixel of mouse movement
const TILT_LIMIT := 0.50         # max tilt in radians (~14 degrees), clamp so it doesn't over-rotate
const TILT_LERP := 0.1           # how snappily it chases the target tilt, lower = floatier
const DRAG_SCALE_MULTIPLIER := 1.05  # subtle scale-up to feel "lifted"

func process(delta: float) -> void:
	if abs(card_UI.rotation) > 0.001:
		card_UI.rotation = lerp(card_UI.rotation, 0.0, TILT_LERP)
	else:
		card_UI.rotation = 0.0

func enter() -> void:
	card_UI.drop_point_detector.monitoring = true
	if card_UI.tween and card_UI.tween.is_running():
		card_UI.tween.kill()
	card_UI.tween = card_UI.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	card_UI.tween.tween_property(card_UI, "scale", card_UI.original_scale * DRAG_SCALE_MULTIPLIER, 0.15)
	

func exit() -> void:
	card_UI.tween = card_UI.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	card_UI.tween.tween_property(card_UI, "rotation", 0.0, 0.2)

func on_input(event: InputEvent) -> void:
	var single_targeted := card_UI.card_data.is_SingleTarget()
	var mouse_motion := event is InputEventMouseMotion
	var cancel = event.is_action("mouse_right")
	var confirm = event.is_action_released("mouse_left") or event.is_action_pressed("mouse_left")
	if card_UI.player_stats.card_IsPlayable(card_UI.card_data):
		if single_targeted and mouse_motion and card_UI.targets.size() > 0:
			TransitionRequest.emit(self, CardState.State.TARGETING)
		if mouse_motion:
			card_UI.global_position = card_UI.get_global_mouse_position() - card_UI.drag_offset
			var target_tilt = clamp(event.relative.x * TILT_FACTOR, -TILT_LIMIT, TILT_LIMIT)
			card_UI.rotation = lerp(card_UI.rotation, target_tilt, TILT_LERP)

		if cancel:
			TransitionRequest.emit(self, CardState.State.IDLING)
		elif confirm:
			get_viewport().set_input_as_handled()
			TransitionRequest.emit(self, CardState.State.RELEASED)
	else:
		TransitionRequest.emit(self, CardState.State.IDLING)
