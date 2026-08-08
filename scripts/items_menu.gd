class_name ItemsMenu
extends PanelContainer
@onready var ItemsContainer: VBoxContainer = $MainContainer/ScrollContainer/HBoxContainer/Items
@onready var QuantitiesContainer: VBoxContainer = $MainContainer/ScrollContainer/HBoxContainer/Quantities
@onready var Description: RichTextLabel = $MainContainer/TooltipContainer/ScrollContainer/RichTextLabel

@export var ItemScene : PackedScene
@export var QuantityScene: PackedScene

var player_inventory : Inventory


func setup_items() -> Array[Item]:
	return player_inventory.inventory.keys()

func setup_quantities() -> Array[int]:
	var quantities = []
	for i in player_inventory.inventory.keys():
		quantities.append(player_inventory.inventory[i])
	return quantities

func display_items_and_quantities() -> void:
	for i in range(player_inventory.inventory.keys().size()):
		var button = ItemScene.instantiate() as Button
		var label = QuantityScene.instantiate() as Label
		var item = player_inventory.inventory.keys()[i] as Item
		var quantity = player_inventory.inventory[item]
		button.icon = item.item_icon
		button.text = item.item_name
		label.text = str(quantity)
		ItemsContainer.add_child(button)
		QuantitiesContainer.add_child(label)
