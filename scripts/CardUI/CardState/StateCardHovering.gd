extends CardState
## Aiming a single-target card (this node's `state` must be TARGETING).
## Capture state: uses on_input only.

const MOUSE_Y_SNAPBACKTHRESHOLD := 650
const TARGET_OFFSET := Vector2(300, -150)

var move_tween: Tween


func uses_global_input() -> bool:
	return true


func enter() -> void:
	card_UI.targets.clear()
	card_UI.sfx.stream = card_UI.aimingSFX
	card_UI.sfx.play()
	card_UI.card_targeting = true
	card_UI.z_index = 100
	card_UI.drop_point_detector.monitoring = false

	if move_tween and move_tween.is_valid():
		move_tween.kill()
	move_tween = card_UI.create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(card_UI, "global_position", card_UI.parent.position + TARGET_OFFSET, 0.2)

	Events.card_aim_started.emit(card_UI)


func exit() -> void:
	if move_tween and move_tween.is_valid():
		move_tween.kill()
	card_UI.z_index = card_UI.get_index()
	Events.card_aim_finished.emit(card_UI)
	card_UI.card_targeting = false
	card_UI.sfx.stop()


func on_input(event: InputEvent) -> void:
	var mouse_motion := event is InputEventMouseMotion
	var mouse_at_bottom := card_UI.get_global_mouse_position().y > MOUSE_Y_SNAPBACKTHRESHOLD

	if (mouse_at_bottom and mouse_motion) or event.is_action_pressed("mouse_right"):
		request_transition(State.IDLING)
	elif event.is_action_pressed("mouse_left"):
		# Swallow the press so it doesn't also click whatever is under the cursor
		# (e.g. an enemy button). Releases are deliberately NOT swallowed: eating
		# a release in _input can leave the viewport's mouse-button state stuck.
		get_viewport().set_input_as_handled()
		request_transition(State.RELEASED)
	elif event.is_action_released("mouse_left"):
		request_transition(State.RELEASED)
