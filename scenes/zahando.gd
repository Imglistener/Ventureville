extends Control

@export var card_scene: PackedScene
@export var draw_delay: float = 0.08

@onready var hand: HBoxContainer = $Hand
@onready var battle_manager: Battle_Manager = %Battle_Manager

var drawn: bool = false


func draw_cards(amount: int) -> void:
	drawn = true
	
	for i in range(amount):
		var card: Control = card_scene.instantiate()
		hand.add_child(card)
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
