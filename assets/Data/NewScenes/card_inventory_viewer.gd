class_name CardInventoryContainer
extends MarginContainer


var selected_card : CardUI
@onready var functionality: CardInventoryViewer = $Functionality
@export var card_manager : DeckEditor

func set_selected_card(card : CardUI) -> void:
	selected_card = card
	card_manager.set_selected_card(card)
