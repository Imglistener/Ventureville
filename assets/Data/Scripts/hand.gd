class_name CardHand extends Node2D

@export var spread_distance := 90.0    # hand-local px pushed onto the immediate neighbours
@export var spread_falloff := 0.6      # each further card gets this fraction of the previous
@export var spread_rotation := 0.08 
@export var spacing: int
@onready var targeting_area: Node2D = $"../../../../../../Node2D_Layer/TargetingArea"
@onready var player_stat_manager: Stat_Manager =$"../../../../../../Functionality/PlayerStatManager"
@onready var deck_manager: DeckManager = $"../../../../../../Functionality/DeckManager"

var is_retaining_hand = false
var is_card_highlighted: bool
var is_arranging: bool = false
var is_hand_hidden = false
var focused_card: CardUI
var _entrance_counter := 0
# Lets overlapping arrange_hand() calls agree on who clears is_arranging.
var _arrange_serial := 0

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
		var state := c.card_state_manager.current_state as CardState
		if c != focused_card and state and state.state == CardState.State.IDLING:
			c.animate_to_hand()
	

func start_turn() -> void:
	if not player_stat_manager.is_node_ready():
		await player_stat_manager.ready
	if not deck_manager.is_node_ready():
		await deck_manager.ready
	await draw_card(player_stat_manager.Entity.draw_power)


func draw_card(amount: int) -> void:
	_entrance_counter = 0 
	for i in range(amount):
		var CardScene = deck_manager.ready_card_drawn()
		add_child(CardScene)
		CardScene.global_position = CardScene.spawn_global_pos
		if not CardScene.is_node_ready():
			await CardScene.ready
		Events.card_drawn.emit(CardScene.card_data)
		await arrange_hand()
	define_playable()


func _is_carried(card: CardUI) -> bool:
	var s := card.card_state_manager.current_state if card.card_state_manager else null
	return s != null and (s.uses_global_input() or s.state == CardState.State.RELEASED)

var _arrange_running: bool = false
var _arrange_requested: bool = false

func arrange_hand() -> void:
	_arrange_requested = true
	if _arrange_running:
		return
	_arrange_running = true
	is_arranging = true
	while _arrange_requested:
		_arrange_requested = false
		await _arrange_pass()
	is_arranging = false
	_arrange_running = false


func _arrange_pass() -> void:
	var max_offset: int = 550
	var offset: float = max_offset * (float(get_child_count()) / 6)
	var curve_height: int = 60

	var final_pos: Vector2
	var final_rot: float
	var running_tweens: Array[Tween] = []

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
			i.hand_position = final_pos
			i.hand_rotation = final_rot
			i.hand_position_set = true
			if _is_carried(i):
				continue
			if i.hand_tween and i.hand_tween.is_valid():
				i.hand_tween.kill()

			var pos_time: float
			var rot_time: float
			if not i.has_entered_hand:
				_entrance_counter += 1
				pos_time = 0.03 + (_entrance_counter * 0.075)
				rot_time = 0.1 + (_entrance_counter * 0.075)
				i.has_entered_hand = true
			else:
				pos_time = 0.03
				rot_time = 0.1

			var tween = i.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
			tween.tween_property(i, "position", final_pos, pos_time)
			tween.tween_property(i, "rotation", final_rot, rot_time)
			i.hand_tween = tween
			running_tweens.append(tween)

	for t in running_tweens:
		if t.is_valid() and t.is_running():
			await t.finished
func define_playable() -> void:
	for i in get_children():
		i.z_index = i.get_index()
		i.is_playable.z_as_relative = true
		i.is_playable.z_index = i.get_index()-1
	
		if i.card_data.mp_cost <= player_stat_manager.Player.mana and i.card_data.ap_cost <= player_stat_manager.Player.AP:
			i.is_playable.visible = true
			i.is_playable.z_as_relative = false
			i.is_playable.z_index = i.get_index()  
		else:
			i.is_playable.visible = false
			i.is_playable.z_as_relative = true
			i.is_playable.z_index = i.get_index() - 1
	Events.turn_cards_drawn.emit()

func hide_hand() -> void: 
	var hiding_tween = create_tween()
	hiding_tween.tween_property(self, 'position', Vector2(112.187, 309.23 + 300), 0.3).set_ease(Tween.EASE_OUT)
	is_hand_hidden = true
	await hiding_tween.finished

func show_hand() -> void:
	var showing_tween = create_tween()
	showing_tween.tween_property(self, 'position', Vector2(112.187, 309.23), 0.3).set_ease(Tween.EASE_OUT)
	is_hand_hidden = false
	await showing_tween.finished
	
func clear_hand() -> void:
	for child in get_children():
		if child is CardUI:
			if not child:
				continue
			child.animate_out()
	await get_tree().create_timer(0.2).timeout
