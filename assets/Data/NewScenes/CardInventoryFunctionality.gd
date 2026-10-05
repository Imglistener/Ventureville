class_name CardInventoryViewer
extends Node

const CARD_SIZE := Vector2(150.0, 236.0)
const EMPTY_TINT := Color(0.41, 0.41, 0.41, 1.0)

var deck : Deck
@export var card_scene : PackedScene
@export var character_stats: CharacterInstance
@onready var search_bar: LineEdit = $"../NinePatchRect/MarginContainer/VBoxContainer/MarginContainer/TextureRect/MarginContainer/HBoxContainer/SearchBar"
@onready var filter_button: TextureButton = $"../NinePatchRect/MarginContainer/VBoxContainer/MarginContainer/TextureRect/MarginContainer/HBoxContainer/FilterButton"
@onready var card_inventory_viewer: CardInventoryContainer = $".."
@onready var cards_view: GridContainer = $"../NinePatchRect/MarginContainer/VBoxContainer/MarginContainer2/ScrollContainer/DeckView"

func _ready() -> void:
	deck = character_stats.starting_deck

func initialize_cards_view() -> void:
	deck = character_stats.starting_deck if character_stats else null
	if not deck or not card_scene or not character_stats:
		return
	for child in cards_view.get_children():
		cards_view.remove_child(child)
		child.queue_free()
	for card in deck.Obtained_Cards.keys():
		var ui := card_scene.instantiate() as CardUI
		ui.Mode = CardUI.CardMode.DISPLAYING
		ui.card_data = card
		ui.player_stats = character_stats
		cards_view.add_child(ui)
		ui.set_display_size(CARD_SIZE)
		ui.amount_owned_container.show()
		ui.CardClicked.connect(card_clicked_propagate)
	refresh_amounts()

## Available = owned - already in deck. Call after any add/remove.
func refresh_amounts() -> void:
	if not deck:
		return
	for ui in cards_view.get_children():
		if ui is CardUI:
			var available := deck.get_available(ui.card_data)
			ui.amount_owned.text = str(available)
			ui.modulate = Color.WHITE if available > 0 else EMPTY_TINT

func card_clicked_propagate(card: CardUI) -> void:
	card_inventory_viewer.set_selected_card(card)
