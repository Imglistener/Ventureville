extends BuffCard
## Attaches Essence Vampirism (which upgrades itself into Gluttony / Voracity on its own).
## Set `condition` to essence_vampirism.tres. No sacrifice by default; set blood_tax in the .tres if wanted.

@export var condition: BattleCondition


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	_activate_condition(condition, targets)
