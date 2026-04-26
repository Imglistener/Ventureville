class_name CardHand extends Node2D

@export var spacing: int
@onready var targeting_area: Node2D = $"../../../../../../Node2D_Layer/TargetingArea"
@onready var player_stat_manager: Stat_Manager =$"../../../../../../Functionality/PlayerStatManager"
@onready var deck_manager: DeckManager = $"../../../../../../Functionality/DeckManager"

var is_card_highlighted: bool


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
		
		#await CardScene.move_cad(CardScene, start_pos, Vector2(i*spacing, CardScene.global_position.y), 0.5)
func arrange_hand():
	var offset: int = 250
	
	var final_pos: Vector2
	var final_rot: float
	
	for i in get_children():
		var hand_ratio: float = 0.5
		if get_child_count() > 1:
			if i:
				hand_ratio = float(i.get_index()) / (float(get_child_count()) - 1.0)
				final_pos = Vector2(hand_ratio * offset, 0)
				final_rot = lerp_angle(-0.2, 0.2, float(i.get_index()) / float(get_child_count() - 1))
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
			await tween.finished

func define_playable() -> void:
	for i in get_children():
		# Stack cards left-to-right so rightmost is on top
		i.z_index = i.get_index()
		i.is_playable.z_as_relative = true
		i.is_playable.z_index = -1
	
		if i.card_data.mp_cost <= player_stat_manager.Player.mana and i.card_data.ap_cost <= player_stat_manager.Player.AP:
			i.is_playable.visible = true
			i.is_playable.z_as_relative = false
			i.is_playable.z_index = i.get_index()  # Match parent card's z_index exactly
		else:
			i.is_playable.visible = false
			i.is_playable.z_as_relative = true
			i.is_playable.z_index = 0
