class_name AddRemoveFunctionality
extends Node

@onready var add_button: TextureButton = $"../../MainVBox/AddRemoveMargin/NinePatchRect/MarginContainer/HBoxContainer/AddButtonMargin/AddButton"
@onready var remove_button: TextureButton = $"../../MainVBox/AddRemoveMargin/NinePatchRect/MarginContainer/HBoxContainer/RemoveButtonMargin/RemoveButton"
@onready var functionality: CardViewerEditor = $".."

func _ready() -> void:
	if not functionality.is_node_ready():
		await functionality.ready
	# No .bind(): read the CURRENTLY displayed card at press time.
	add_button.pressed.connect(_on_add_button_pressed)
	remove_button.pressed.connect(_on_remove_button_pressed)

func _on_add_button_pressed() -> void:
	if functionality.card_displayed:
		Events.add_card_to_deck_request.emit(functionality.card_displayed)

func _on_remove_button_pressed() -> void:
	if functionality.card_displayed:
		Events.remove_card_from_deck_request.emit(functionality.card_displayed)
