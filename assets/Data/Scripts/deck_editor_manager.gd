class_name DeckEditorManager
extends Node

@onready var card_viewer_container: CardViewerContainer = $"../MainEditorContainer/CardViewerContainer"
@onready var deck_editor_viewer: DeckEditorContainer = $"../MainEditorContainer/DeckEditorViewer"
@onready var card_inventory_viewer: CardInventoryContainer = $"../MainEditorContainer/CardInventoryViewer"

var deck : Deck

func initialize_deck() -> void:
	deck = deck_editor_viewer.functionality.character_stats.starting_deck
	if not Events.add_card_to_deck_request.is_connected(deck.add_card_to_deck):
		Events.add_card_to_deck_request.connect(deck.add_card_to_deck)
	if not Events.remove_card_from_deck_request.is_connected(deck.remove_card_from_deck):
		Events.remove_card_from_deck_request.connect(deck.remove_card_from_deck)
	if not Events.clear_deck_request.is_connected(deck.clear_deck_to_collection):
		Events.clear_deck_request.connect(deck.clear_deck_to_collection)
	if not Events.save_deck_request.is_connected(_on_save_requested):
		Events.save_deck_request.connect(_on_save_requested)
	if not deck.card_added_to_deck.is_connected(_on_deck_changed):
		deck.card_added_to_deck.connect(_on_deck_changed)
	if not deck.card_removed_from_deck.is_connected(_on_deck_changed):
		deck.card_removed_from_deck.connect(_on_deck_changed)
	_on_deck_changed()

func _on_deck_changed() -> void:
	deck_editor_viewer.functionality.update_deckview()
	card_inventory_viewer.functionality.refresh_amounts()
	card_viewer_container.functionality.display_card()
func _on_save_requested() -> void:
	var counts = deck_editor_viewer.functionality.get_displayed_counts()
	deck.reconcile_in_deck(counts)
	var err = deck.save_to_disk()
	if err == OK:
		print("Deck saved.")
	else:
		push_warning("Deck save failed: %s" % error_string(err))

func _exit_tree() -> void:
	if not deck:
		return
	if Events.add_card_to_deck_request.is_connected(deck.add_card_to_deck):
		Events.add_card_to_deck_request.disconnect(deck.add_card_to_deck)
	if Events.remove_card_from_deck_request.is_connected(deck.remove_card_from_deck):
		Events.remove_card_from_deck_request.disconnect(deck.remove_card_from_deck)
	if Events.clear_deck_request.is_connected(deck.clear_deck_to_collection):
		Events.clear_deck_request.disconnect(deck.clear_deck_to_collection)
	if Events.save_deck_request.is_connected(_on_save_requested):
		Events.save_deck_request.disconnect(_on_save_requested)
	if deck.card_added_to_deck.is_connected(_on_deck_changed):
		deck.card_added_to_deck.disconnect(_on_deck_changed)
	if deck.card_removed_from_deck.is_connected(_on_deck_changed):
		deck.card_removed_from_deck.disconnect(_on_deck_changed)
