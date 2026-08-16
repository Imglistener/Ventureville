class_name ItemsMenu
extends PanelContainer


@onready var ItemsContainer: VBoxContainer = $MainContainer/ScrollContainer/HBoxContainer/Items
@onready var QuantitiesContainer: VBoxContainer = $MainContainer/ScrollContainer/HBoxContainer/Quantities
@onready var Description: RichTextLabel = $MainContainer/TooltipContainer/ScrollContainer/ItemDescription

@export var ItemScene : PackedScene
@export var QuantityScene: PackedScene

var items_quantities : Dictionary = {}
var player_inventory : Inventory
var tree : SceneTree


func _ready() -> void:
	tree = get_tree()
	if not Events.PlayerStandbyStart.is_connected(update_items_and_quantities):
		Events.PlayerStandbyStart.connect(update_items_and_quantities.unbind(1))

func update_items_and_quantities() -> void:
	var current_ap: int = get_tree().get_first_node_in_group('player').Player.AP
	for quantity in QuantitiesContainer.get_children():
		if quantity is quantity_label:
			var item: Item = quantity.governed_button.item_displayed
			if player_inventory.inventory.has(item) and player_inventory.inventory[item] > 0:
				quantity.text = str(player_inventory.inventory[item])
			else:
				quantity.governed_button.queue_free()
				quantity.queue_free()
			for item_btn in ItemsContainer.get_children():
				if item_btn is item_button:
					item_btn.disabled = item_btn.item_displayed.item_cost > current_ap

func display_items_and_quantities() -> void:
	for item in player_inventory.inventory.keys():
		var item_x = ItemScene.instantiate() as item_button
		item_x.item_displayed = item
		ItemsContainer.add_child(item_x)
		item_x.pressed.connect(use_item.bind(item))
		item_x.is_highlighted.connect(update_description)
		var quantity_x = QuantityScene.instantiate() as quantity_label
		quantity_x.governed_button = item_x
		quantity_x.text = str(player_inventory.inventory[item])
		QuantitiesContainer.add_child(quantity_x)

func use_item(item : Item) -> void:
	if not item:
		return
	if item.item_cost <= get_tree().get_first_node_in_group('player').Player.AP:
		item.item_effect.apply_effect(tree.get_first_node_in_group('player'))
		player_inventory.remove_item(item, 1)
		get_tree().get_first_node_in_group('player').Player.AP -= item.item_cost
	for selection in ItemsContainer.get_children():
		if selection is Button:
			if selection.text == item.item_name:
				if item.item_cost > get_tree().get_first_node_in_group('player').Player.AP:
					selection.disabled = true
	update_items_and_quantities()
	Events.item_used.emit(item)

func update_description(item: Item) -> void: 
	Description.text = item.item_description + " [Cost: %s AP]" %item.item_cost 
