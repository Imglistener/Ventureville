class_name Inventory
extends Resource

@export var inventory : Dictionary

func list_inventory() -> Dictionary:
	return inventory

func add_item(item : Item, amount: int) -> void:
	if item not in inventory.keys():
		inventory[item] = amount
	else:
		inventory[item] += amount

func remove_item(item: Item, amount: int) -> void:
	if item not in inventory.keys():
		return
	else:
		if inventory[item] <= amount:
			inventory.erase(item)
		else:
			inventory[item] -= amount
	if inventory[item] == 0:
		inventory.erase(item)

func new_inventory() -> Resource:
	inventory.clear()
	return self
