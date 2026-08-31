class_name CardHand extends Node2D

@export var spacing: int
@onready var targeting_area: Node2D = $"../../../../../../Node2D_Layer/TargetingArea"
@onready var player_stat_manager: Stat_Manager =$"../../../../../../Functionality/PlayerStatManager"
@onready var deck_manager: DeckManager = $"../../../../../../Functionality/DeckManager"

var is_card_highlighted: bool
var is_arranging: bool = false


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
		if i:
			var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			tween.parallel().tween_property(i, "position", final_pos, 0.03 + (i.get_index() * 0.075))
			tween.parallel().tween_property(i, "rotation", final_rot, 0.2 + (i.get_index() * 0.075))
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
	
		if i.card_data.mp_cost <= player_stat_manager.Player.mana and i.card_data.ap_cost <= player_stat_manager.Player.AP and not i.card_disabled:
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
