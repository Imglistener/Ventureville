extends BuffCard

@export var condition: BattleCondition

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)   # paid BEFORE the condition exists, so the card doesn't trigger itself
	_activate_condition(condition, targets)
