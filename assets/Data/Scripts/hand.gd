class_name CardHand extends Node2D

@export var spread_distance := 90.0    # hand-local px pushed onto the immediate neighbours
@export var spread_falloff := 0.6      # each further card gets this fraction of the previous
@export var spread_rotation := 0.08 
@export var spacing: int
@onready var targeting_area: Node2D = $"../../../../../../Node2D_Layer/TargetingArea"
@onready var player_stat_manager: Stat_Manager =$"../../../../../../Functionality/PlayerStatManager"
@onready var deck_manager: DeckManager = $"../../../../../../Functionality/DeckManager"

var is_card_highlighted: bool
var is_arranging: bool = false
var focused_card: CardUI

func _ready() -> void:
	if not Events.calling_arrange_hand.is_connected(arrange_hand):
		Events.calling_arrange_hand.connect(arrange_hand)


func set_focus(card: CardUI) -> void:
	focused_card = card
	_apply_focus()

func clear_focus(card: CardUI) -> void:
	if focused_card != card:   # A's exit can run after B's enter
		return
	focused_card = null
	_apply_focus()

func _apply_focus() -> void:
	var focus_index := focused_card.get_index() if focused_card else -1
	for c in get_children():
		if not c is CardUI:
			continue
		if focus_index == -1 or c == focused_card:
			c.focus_offset = Vector2.ZERO
			c.focus_rotation = 0.0
		else:
			var dist: int = c.get_index() - focus_index
			var dir := signf(dist)
			var strength := pow(spread_falloff, absi(dist) - 1)
			c.focus_offset = Vector2(dir * spread_distance * strength, 0.0)
			c.focus_rotation = dir * spread_rotation * strength
		# only cards resting in the hand get animated; the others pick the offset up later
		var state := c.card_state_manager.current_state as CardState
		if c != focused_card and state and state.state == CardState.State.IDLING:
			c.animate_to_hand()

func start_turn() -> void:
	if not player_stat_manager.is_node_ready():
		await player_stat_manager.ready
	if not deck_manager.is_node_ready():
		await deck_manager.ready
	draw_card(player_stat_manager.Entity.draw_power)
	define_playable()
	arrange_hand()

func draw_card(amount: int) -> void:
	for i in range(amount):
		var CardScene = deck_manager.ready_card_drawn()
		add_child(CardScene)
		Events.card_drawn.emit(CardScene.card_data)
		arrange_hand()
		

func arrange_hand():
	is_arranging = true
	var max_offset: int = 550
	var offset: float = max_offset * (float(get_child_count()) / 6)
	var curve_height: int = 60  # tweak to taste

	var final_pos: Vector2
	var final_rot: float
	var last_tween: Tween
	for i in get_children():
		var hand_ratio: float = 0.5
		if get_child_count() > 1:
			hand_ratio = float(i.get_index()) / (float(get_child_count()) - 1.0)
			var curve_y: float = -curve_height * 4.0 * hand_ratio * (1.0 - hand_ratio)
			final_pos = Vector2(hand_ratio * offset, curve_y)
			final_rot = lerp_angle(-0.4, 0.4, hand_ratio)
		else:
			final_rot = 0
			final_pos = Vector2(50, 0)
		if i is CardUI:
			if i.hand_tween and i.hand_tween.is_valid():
				i.hand_tween.kill()
			var tween = i.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
			tween.tween_property(i, "position", final_pos, 0.03 + (i.get_index() * 0.075))
			tween.tween_property(i, "rotation", final_rot, 0.2 + (i.get_index() * 0.075))
			i.hand_tween = tween
			i.hand_position = final_pos
			i.hand_rotation = final_rot
			i.hand_position_set = true
			last_tween = tween

				

	# Await only once, after all tweens are started
	if last_tween:
		await last_tween.finished
	
	is_arranging = false
func define_playable() -> void:
	for i in get_children():
		# Stack cards left-to-right so rightmost is on top
		i.z_index = i.get_index()
		i.is_playable.z_as_relative = true
		i.is_playable.z_index = i.get_index()-1
	
		if i.card_data.mp_cost <= player_stat_manager.Player.mana and i.card_data.ap_cost <= player_stat_manager.Player.AP:
			i.is_playable.visible = true
			i.is_playable.z_as_relative = false
			i.is_playable.z_index = i.get_index()  # Match parent card's z_index exactly
		else:
			i.is_playable.visible = false
			i.is_playable.z_as_relative = true
			i.is_playable.z_index = i.get_index() - 1

func clear_hand() -> void:
	for child in get_children():
		if child is CardUI:
			if not child:
				continue
			child.animate_out()
	await get_tree().create_timer(0.2).timeout
