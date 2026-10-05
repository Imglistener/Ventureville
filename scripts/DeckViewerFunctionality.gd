class_name DeckViewer
extends Node

const CARD_SIZE := Vector2(150.0, 236.0)

@onready var deck_view: GridContainer = $"../DeckViewerBackground/MarginContainer/ScrollContainer/DeckView"
@onready var deck_editor_viewer: DeckEditorContainer = $".."
@export var card_scene : PackedScene
@export var character_stats: CharacterInstance
var deck : Deck


func _ready() -> void:
	_refresh_deck_reference()

func _refresh_deck_reference() -> void:
	deck = character_stats.starting_deck if character_stats else null

func initialize_deckview() -> void:
	_refresh_deck_reference()
	if not deck or not card_scene or not character_stats:
		return
	for child in deck_view.get_children():
		deck_view.remove_child(child)
		child.queue_free()
	for card in deck.Card_Amount_In_Deck.keys():
		for i in range(deck.get_in_deck(card)):
			_add_card_ui(card)

func _add_card_ui(card: Card) -> CardUI:
	var ui := card_scene.instantiate() as CardUI
	ui.Mode = CardUI.CardMode.DISPLAYING
	ui.card_data = card
	ui.player_stats = character_stats 
	deck_view.add_child(ui)
	ui.set_display_size(CARD_SIZE)
	ui.CardClicked.connect(card_clicked_propagate)
	return ui

func card_clicked_propagate(card: CardUI) -> void:
	deck_editor_viewer.set_selected_card(card)

## Diffs the grid against the deck: frees extras, adds missing copies.
func update_deckview() -> void:
	if not deck:
		return
	var shown_by_card: Dictionary = {}   # Card -> Array of CardUI
	for child in deck_view.get_children():
		if child is CardUI and not child.is_queued_for_deletion():
			if not shown_by_card.has(child.card_data):
				shown_by_card[child.card_data] = []
			shown_by_card[child.card_data].append(child)

	for card in deck.Card_Amount_In_Deck.keys():
		var wanted = deck.get_in_deck(card)
		var shown: Array = shown_by_card.get(card, [])
		while shown.size() > wanted:
			_remove_card_ui(shown.pop_back())
		while shown.size() < wanted:
			shown.append(_add_card_ui(card))

	# cards whose key vanished from the dictionary entirely
	for card in shown_by_card.keys():
		if not deck.Card_Amount_In_Deck.has(card):
			for ui in shown_by_card[card]:
				_remove_card_ui(ui)
				

func _remove_card_ui(ui: CardUI) -> void:
	deck_view.remove_child(ui)   # leave the grid immediately, free at end of frame
	ui.queue_free()

func _clear_deck() -> void:
	for child in deck_view.get_children():
		if not child:
			continue
		if child is CardUI:
			deck.Card_Amount_In_Deck[child.card_data] = 0
	
	update_deckview()
	
func get_displayed_counts() -> Dictionary:
	var counts: Dictionary = {}
	for child in deck_view.get_children():
		if child is CardUI and not child.is_queued_for_deletion():
			counts[child.card_data] = counts.get(child.card_data, 0) + 1
	return counts
