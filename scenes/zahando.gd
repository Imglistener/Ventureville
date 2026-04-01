extends Control

@export var card_scene: PackedScene
@export var draw_delay: float = 0.08

@onready var hand: HBoxContainer = $Hand
@onready var battle_manager: Battle_Manager = %Battle_Manager
@onready var deck_manager: Deck_Manager = $"../../../../../../Deck_Manager"

var cards_in_hand : Array = []

var drawn: bool = false
var is_playable : bool = false

signal cards_drawn
signal card_instantiated(card : Node)

func activate_playable_cards() -> void:
	for drawn_card in hand.get_children():
		if drawn_card.is_destroying:
			await drawn_card.tree_exited
		if drawn_card is Button:
			if drawn_card.card_data.Action_Cost_AP > battle_manager.action_points or drawn_card.card_data.Action_Cost_MP > battle_manager.mana_counter:
					drawn_card.disabled = true

func clear_hand() -> void:
	for card in cards_in_hand:
		if card:
			card.queue_free()
		else: pass
func draw_cards(amount: int) -> void:
	deck_manager.manage_deckout()
	drawn = true
	for i in range(0, amount):
		var card: Control = card_scene.instantiate()
		hand.add_child(card)
		deck_manager.apply_template(card)
		battle_manager.register_card(card)
		card.base_position = card.position

		# Wait for container layout
		await get_tree().process_frame
		
		# Start state
		card.modulate.a = 0.0
		card.scale = Vector2(0.8, 0.8)
		card.position.y += 40
		# ✅ Create a NEW tween for THIS card
		var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		t.tween_property(card, "modulate:a", 1.0, 0.25)
		t.parallel().tween_property(card, "scale", Vector2.ONE, 0.25)
		t.parallel().tween_property(card, "position:y", 0, 0.3)
		
		await get_tree().create_timer(draw_delay).timeout
		activate_playable_cards()
		emit_signal("cards_drawn")
		cards_in_hand.append(card)


func _on_battle_manager_card_played(card_data: Variant) -> void:
	activate_playable_cards()





func _on_battle_manager_player_battle_phase_end() -> void:
	clear_hand()
	deck_manager.clear_hand()
