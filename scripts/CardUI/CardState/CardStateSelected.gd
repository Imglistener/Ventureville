extends CardState

var t: Tween

func _ready() -> void:
	Events.card_unselected.connect(on_card_unselected)

func enter() -> void:
	if card_UI.card_dragging == true: return
	if card_UI.is_displaying == true: return
	is_card_focused(true)

func exit() -> void:
	is_card_focused(false)

func animate_card(type: int) -> void:
	if t:
		t.kill()
	t = create_tween().set_parallel(true)

	card_UI.is_selected = true
	
	match type:
		0:
			t.tween_property(card_UI, "rotation", 0.0, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t.tween_property(card_UI, "scale", Vector2(0.42 , 0.42), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

			var target_local_y: float = -160.0 
			var target_pos := Vector2(card_UI.hand_position.x, target_local_y)

			t.tween_property(card_UI, "position", target_pos, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		1:
			t.tween_property(card_UI, "scale", card_UI.original_scale, 0.55).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			card_UI.is_selected = false
	await t.finished

func on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		card_UI.drag_offset = card_UI.get_global_mouse_position() - card_UI.global_position
		TransitionRequest.emit(self, CardState.State.CLICKED)

func is_card_focused(value: bool) -> void:
	if value:
		card_UI.z_index = 100
		card_UI.sfx.stream = card_UI.HoverSFX
		card_UI.sfx.play()
		await animate_card(0)
	else:
		card_UI.z_index = get_index()             
		await animate_card(1)

func on_card_unselected(card : CardUI) -> void:
	if get_viewport().gui_get_hovered_control():
		if get_viewport().gui_get_hovered_control() == card:
			return
	TransitionRequest.emit(self, CardState.State.IDLING)
