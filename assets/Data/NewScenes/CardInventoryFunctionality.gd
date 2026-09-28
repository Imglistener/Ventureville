class_name CardInventoryViewer
extends Node

var deck : Deck 
@export var card_scene : PackedScene
@export var character_stats: CharacterInstance
@onready var search_bar: LineEdit = $"../NinePatchRect/MarginContainer/VBoxContainer/MarginContainer/TextureRect/MarginContainer/HBoxContainer/SearchBar"
@onready var filter_button: TextureButton = $"../NinePatchRect/MarginContainer/VBoxContainer/MarginContainer/TextureRect/MarginContainer/HBoxContainer/FilterButton"
@onready var card_inventory_viewer: CardInventoryContainer = $".."
@onready var amount_owned_functionality: AmountOwnedManager = $AmountOwnedFunctionality

@onready var cards_view: GridContainer = $"../NinePatchRect/MarginContainer/VBoxContainer/MarginContainer2/ScrollContainer/DeckView"

func _ready() -> void:
	deck = character_stats.starting_deck

	
	
func initialize_cards_view() -> void:
	if not deck:
		return
	if not card_scene:
		return
	if not character_stats:
		return
	var card_inventory = deck.Obtained_Cards
	for card in card_inventory.keys():
		var card_scene_instance = card_scene.instantiate() as CardUI
		card_scene_instance.Mode = CardUI.CardMode.DISPLAYING
		card_scene_instance.card_data = card
		cards_view.add_child(card_scene_instance)
		card_scene_instance.set_display_size(Vector2(150.0, 236.0))
		card_scene_instance.player_stats = character_stats
		card_scene_instance.update_description()
		card_scene_instance.amount_owned_container.show()
		card_scene_instance.amount_owned.text = str(card_inventory[card] - deck.Card_Amount_In_Deck[card])
		card_scene_instance.CardClicked.connect(card_clicked_propagate)
	amount_owned_functionality.update_amount_owned_labels()
	amount_owned_functionality.modulate_cards_empty()

func card_clicked_propagate(card: CardUI) -> void:
	card_inventory_viewer.set_selected_card(card)
