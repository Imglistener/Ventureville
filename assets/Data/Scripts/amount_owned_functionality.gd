class_name AmountOwnedManager
extends Node

@onready var inventory_view: GridContainer = $"../../NinePatchRect/MarginContainer/VBoxContainer/MarginContainer2/ScrollContainer/DeckView"
@onready var card_inventory_viewer: CardInventoryContainer = $"../.."

var amount_owned_labels : Array[Label]

func _ready() -> void:
	if not card_inventory_viewer.is_node_ready():
		await card_inventory_viewer.ready


func update_amount_owned_labels() -> void:
	amount_owned_labels.clear()
	for card in inventory_view.get_children():
		if card is CardUI:
				amount_owned_labels.append(card.amount_owned)
				

func modulate_cards_empty() -> void:
	for label in amount_owned_labels:
		if not label:
			continue
		if label is AmountOwnedLabel and label.text == "0":
			label.scene_root.modulate = Color(0.41, 0.41, 0.41, 1.0)
