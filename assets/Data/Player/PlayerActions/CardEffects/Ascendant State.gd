extends BuffCard

@export var condition: BattleCondition

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	_activate_condition(condition, targets)
