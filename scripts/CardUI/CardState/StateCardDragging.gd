extends CardState
## Card follows the cursor. Capture state: uses on_input only.

const TILT_FACTOR := 0.04            # how aggressively it tilts per pixel of mouse movement
const TILT_LIMIT := 0.50             # max tilt in radians, clamp so it doesn't over-rotate
const TILT_LERP := 0.1               # how snappily it chases the target tilt, lower = floatier
const DRAG_SCALE_MULTIPLIER := 1.05  # subtle scale-up to feel "lifted"


func uses_global_input() -> bool:
	return true


func enter() -> void:
	card_UI.card_dragging = true
	card_UI.z_index = 100
	card_UI.drop_point_detector.monitoring = true
	if card_UI.tween and card_UI.tween.is_valid():
		card_UI.tween.kill()
	card_UI.tween = card_UI.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	card_UI.tween.tween_property(card_UI, "scale", card_UI.original_scale * DRAG_SCALE_MULTIPLIER, 0.15)


func exit() -> void:
	card_UI.card_dragging = false
	card_UI.reset_live_preview()
	card_UI.tween = card_UI.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	card_UI.tween.tween_property(card_UI, "rotation", 0.0, 0.2)


func process(_delta: float) -> void:
	if absf(card_UI.rotation) > 0.001:
		card_UI.rotation = lerpf(card_UI.rotation, 0.0, TILT_LERP)
	else:
		card_UI.rotation = 0.0


func on_input(event: InputEvent) -> void:
	if not card_UI.player_stats.card_IsPlayable(card_UI.card_data):
		request_transition(State.IDLING)
		return

	var motion := event as InputEventMouseMotion
	if motion:
		card_UI.global_position = card_UI.get_global_mouse_position() - card_UI.drag_offset
		var target_tilt := clampf(motion.relative.x * TILT_FACTOR, -TILT_LIMIT, TILT_LIMIT)
		card_UI.rotation = lerpf(card_UI.rotation, target_tilt, TILT_LERP)
		# Returns right after the request: the state has changed, so don't keep acting on it.
		if card_UI.card_data.is_SingleTarget() and not card_UI.targets.is_empty():
			request_transition(State.TARGETING)
		return

	if event.is_action_pressed("mouse_right"):
		request_transition(State.IDLING)
	elif event.is_action_released("mouse_left") or event.is_action_pressed("mouse_left"):
		request_transition(State.RELEASED)
