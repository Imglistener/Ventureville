class_name DeckEditorContainer
extends MarginContainer

var selected_card : CardUI
@export var card_manager : DeckEditor
@onready var functionality: DeckViewer = $Functionality

func set_selected_card(card : CardUI) -> void:
	selected_card = card
	card_manager.set_selected_card(card)
