class_name CardViewer extends MarginContainer

@export var grid_container: GridContainer
@export var card_scene : PackedScene

func _ready() -> void:
	var player :=  get_tree().get_first_node_in_group('player') as Stat_Manager
	if not player.is_node_ready():
		await player.ready
	var card_deck : Deck = player.Player.starting_deck
	for card in card_deck.Cards_in_Deck:
		if card_deck.Obtained_Cards[card] > 0:
			for i in range(card_deck.Obtained_Cards[card]):
				var card_ui = card_scene.instantiate() as CardUI
				card_ui.player_stats = player.Player
				card_ui.card_data = card
				card_ui.Mode = CardUI.CardMode.DISPLAYING
				grid_container.add_child(card_ui)
				card_ui.set_display_size(Vector2(247.0, 406.5))
			
				card_ui.is_displaying = true
				card_ui.is_playable.hide()
				print("Card Name: ", card.name, " , Card Type: " , Card.Type.find_key(card.type), " , Card Description: " , card.Description)
