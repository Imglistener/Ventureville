class_name CardDisplayFunctionality
extends Node

@export var card_display : PackedScene
@export var player_stats : CharacterInstance

func display_card(card: Card) -> void:
	var card_display_scene : CardDisplayScreen = card_display.instantiate()
	card_display_scene.card_displayed = card
	card_display_scene.player_data = player_stats
	var root_node = get_tree().current_scene if get_tree().current_scene is Control else get_tree().get_first_node_in_group('ControlBase')
	root_node.add_child(card_display_scene)
	card_display_scene.display_card()
	card_display_scene.top_level = true
	
