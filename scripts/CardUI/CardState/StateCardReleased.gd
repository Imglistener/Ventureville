extends CardState
## Card was dropped. Plays it if it has targets, otherwise sends it back to the
## hand. Takes no input.

var played := false


func enter() -> void:
	played = false

	# ORDER MATTERS. Disabling an Area2D's `monitoring` emits area_exited for every
	# overlap, and CardUI._on_area_2d_area_exited erases each one from card_UI.targets.
	# So targets must be read, and play() (which needs them) called, BEFORE monitoring
	# is turned off. Non-single-target cards get their targets from this detector.
	if card_UI.targets.is_empty():
		card_UI.drop_point_detector.monitoring = false
		return   # process() returns it to the hand
	if card_UI.card_data.target == Card.Target.ONEENEMY and card_UI.targets[0] is not EnemyView:
		card_UI.drop_point_detector.monitoring = false
		return
	played = true
	# Grab the hand before play(), which may detach the card from it.
	var hand := card_UI.get_parent() as CardHand
	card_UI.play()
	# Safe now: play() has consumed the targets. The card is only queued for
	# deletion at this point, so its nodes are still valid.
	card_UI.drop_point_detector.monitoring = false
	await card_UI.tree_exited
	if is_instance_valid(hand):
		hand.arrange_hand()
		hand.define_playable()


func process(_delta: float) -> void:
	if not played:
		# IDLING.enter() handles animate_to_hand().
		request_transition(State.IDLING)
