extends CardState

const LIFT_Y := -160.0
const FOLLOW_STRENGTH := 0.45   # fraction of the cursor offset the card moves by
const FOLLOW_MAX := 60.0        # hand-local px
const FOLLOW_SPEED := 18.0
const EXIT_PADDING := 60.0
var hand: CardHand
var follow_x := 0.0
var t: Tween



func enter() -> void:
	if card_UI.card_dragging or card_UI.is_displaying:
		return
	hand = card_UI.get_parent() as CardHand
	if card_UI.tween and card_UI.tween.is_valid():
		card_UI.tween.kill()
	if card_UI.hand_tween and card_UI.hand_tween.is_valid():
		card_UI.hand_tween.kill()
	follow_x = card_UI.position.x - card_UI.hand_position.x   # start from where the card is, no snap
	if hand:
		hand.set_focus(card_UI)
	is_card_focused(true)

func exit() -> void:
	if hand:
		hand.clear_focus(card_UI)
	is_card_focused(false)

func process(delta: float) -> void:
	if not hand or card_UI.card_dragging or card_UI.is_displaying:
		return
	if hand.focused_card != card_UI or not _mouse_over_card():
		TransitionRequest.emit(self, CardState.State.IDLING)
		return
	var rest_center_x := card_UI.hand_position.x + card_UI.pivot_offset.x
	var target := clampf((hand.get_local_mouse_position().x - rest_center_x) * FOLLOW_STRENGTH,
			-FOLLOW_MAX, FOLLOW_MAX)
	follow_x = lerpf(follow_x, target, 1.0 - exp(-FOLLOW_SPEED * delta))
	card_UI.position.x = card_UI.hand_position.x + follow_x

func animate_card(type: int) -> void:
	if t:
		t.kill()
	t = create_tween().set_parallel(true)
	card_UI.is_selected = true
	match type:
		0:
			t.tween_property(card_UI, "rotation", 0.0, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t.tween_property(card_UI, "scale", Vector2(0.42, 0.42), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t.tween_property(card_UI, "position:y", LIFT_Y, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		1:
			t.tween_property(card_UI, "scale", card_UI.original_scale, 0.55).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			card_UI.is_selected = false
	await t.finished

func on_gui_input(event: InputEvent) -> void:
	if card_UI.card_state_manager.current_state.state != CardState.State.SELECTED: 
		print("GUI INPUT OBTAINED ON CARDSTATE SELECTED, but the CURRENTSTATE IS NOT SELECTED SO IT DOES NOTHING. Current STATE IS: ", CardState.State.find_key(card_UI.card_state_manager.current_state.state))
		return
	if event.is_action_pressed("mouse_left"):
		card_UI.drag_offset = card_UI.get_global_mouse_position() - card_UI.global_position
		if card_UI.player_stats.card_IsPlayable(card_UI.card_data):
			print("Is Current State SELECTED? ", card_UI.card_state_manager.current_state.state == CardState.State.SELECTED)
			TransitionRequest.emit(self, CardState.State.CLICKED)



func is_card_focused(value: bool) -> void:
	if value:
		card_UI.z_index = 100
		card_UI.sfx.stream = card_UI.HoverSFX
		card_UI.sfx.play()
		await animate_card(0)
	else:
		card_UI.z_index = card_UI.get_index()             
		await animate_card(1)


	
func _mouse_over_card() -> bool:
	var local := card_UI.get_global_transform().affine_inverse() * card_UI.get_global_mouse_position()
	return Rect2(Vector2.ZERO, card_UI.size).grow(EXIT_PADDING).has_point(local)
