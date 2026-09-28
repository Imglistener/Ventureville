class_name DeckViewer
extends Node

@onready var deck_view: GridContainer = $"../DeckViewerBackground/MarginContainer/ScrollContainer/DeckView"
var deck : Deck 
@export var card_scene : PackedScene
@export var character_stats: CharacterInstance
@onready var deck_editor_viewer: DeckEditorContainer = $".."


func _ready() -> void:
	deck = character_stats.starting_deck

	
func initialize_deckview() -> void:
	if not deck:
		return
	if not card_scene:
		return
	if not character_stats:
		return
	var amount_in_deck : int = deck.Card_Amount_In_Deck.keys().size()
	for card in range(amount_in_deck):
		var card_instance : CardUI = card_scene.instantiate()
		card_instance.Mode = CardUI.CardMode.DISPLAYING
		card_instance.card_data = deck.Card_Amount_In_Deck.keys()[card]
		for copy in range(deck.Card_Amount_In_Deck[card_instance.card_data]):
			var card_instance_dupe = card_instance.duplicate()
			deck_view.add_child(card_instance_dupe)
			card_instance_dupe.player_stats = character_stats
			card_instance_dupe.update_description()
			card_instance_dupe.set_display_size(Vector2(150.0, 236.0))
			card_instance_dupe.CardClicked.connect(card_clicked_propagate)

func card_clicked_propagate(card: CardUI) -> void:
	deck_editor_viewer.set_selected_card(card)

func update_deckview() -> void:
	var cards_displayed : Array[CardUI] = []
	for card in deck_view.get_children():
		if card is CardUI:
			cards_displayed.append(card)
	for card in deck.Card_Amount_In_Deck.keys():
		var card_count: int = 0
		var carduis_found: Array[CardUI] = []
		for cardui in cards_displayed:
			if cardui.card_data == cardui:
				card_count += 1
				carduis_found.append(cardui)
		if card_count == deck.Card_Amount_In_Deck[card]:
			continue
		elif card_count > deck.Card_Amount_In_Deck[card]:
			var difference :=  card_count - deck.Card_Amount_In_Deck[card]
			for i in range(difference):
				if carduis_found[0]:
					carduis_found[0].queue_free()
		elif card_count < deck.Card_Amount_In_Deck[card]:
			var difference = deck.Card_Amount_In_Deck[card] - card_count
			for i in range(difference):
				var new_cardui : CardUI = card_scene.instantiate()
				new_cardui.Mode = CardUI.CardMode.DISPLAYING
				new_cardui.card_data = card
				deck_view.add_child(new_cardui)
				new_cardui.set_display_size(Vector2(150.0, 236.0))
				new_cardui.CardClicked.connect(card_clicked_propagate)
				new_cardui.player_stats = character_stats
				new_cardui.update_description()
