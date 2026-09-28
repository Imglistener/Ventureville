class_name DeckEditorManager
extends Node

@onready var card_viewer_container: CardViewerContainer = $"../MainEditorContainer/CardViewerContainer"
@onready var deck_editor_viewer: DeckEditorContainer = $"../MainEditorContainer/DeckEditorViewer"
@onready var card_inventory_viewer: CardInventoryContainer = $"../MainEditorContainer/CardInventoryViewer"

var deck : Deck

func initialize_deck() -> void:
	deck = deck_editor_viewer.functionality.character_stats.starting_deck
	Events.add_card_to_deck_request.connect(deck.add_card_to_deck)
	Events.remove_card_from_deck_request.connect(deck.remove_card_from_deck)
	deck.card_added_to_deck.connect(deck_editor_viewer.functionality.update_deckview)
	deck.card_removed_from_deck.connect(deck_editor_viewer.functionality.update_deckview)
