class_name AddRemoveFunctionality
extends Node

@onready var add_button: TextureButton = $"../../MainVBox/AddRemoveMargin/NinePatchRect/MarginContainer/HBoxContainer/AddButtonMargin/AddButton"
@onready var remove_button: TextureButton = $"../../MainVBox/AddRemoveMargin/NinePatchRect/MarginContainer/HBoxContainer/RemoveButtonMargin/RemoveButton"
@onready var functionality: CardViewerEditor = $".."

func _ready() -> void:
	if not functionality.is_node_ready():
		await functionality.ready
	if not add_button.pressed.is_connected(_on_add_button_pressed):
		add_button.pressed.connect(_on_add_button_pressed.bind(functionality.card_displayed))
	if not remove_button.pressed.is_connected(_on_remove_button_pressed):
		remove_button.pressed.connect(_on_remove_button_pressed.bind(functionality.card_displayed))
func _on_add_button_pressed(selected_card: Card) -> void:
	Events.add_card_to_deck_request.emit(selected_card)

func _on_remove_button_pressed(selected_card: Card) -> void:
	Events.remove_card_from_deck_request.emit(selected_card)
