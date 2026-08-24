class_name HealingItem
extends ItemEffect

@export var healing_amount: int

func apply_effect(target: Node = tree.get_first_node_in_group('player')) -> void:
	if target is Stat_Manager:
		target.Player.heal(healing_amount)
	else:
		return
