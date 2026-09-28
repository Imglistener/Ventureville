class_name SearchFunctionality
extends Node

@export var searchbar : LineEdit
@onready var card_inventory_view: GridContainer = $"../../NinePatchRect/MarginContainer/VBoxContainer/MarginContainer2/ScrollContainer/DeckView"

var keyword: String

func set_keyword(value: String) -> void:
	keyword = value

func _clear_searchbar() -> void:
	searchbar.clear()

func _update_search_results(value: String) -> void:
	set_keyword(value)
	if value == "":
		for card in card_inventory_view.get_children():
			if card is CardUI:
				card.show()
		return
	for card in card_inventory_view.get_children():
		if card is CardUI:
			if card.card_data.name.to_lower().contains(value.to_lower()) or card.card_data.Description.to_lower().contains(value.to_lower()):
				card.show()
			else:
				card.hide()
