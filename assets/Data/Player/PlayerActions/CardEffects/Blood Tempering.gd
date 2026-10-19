extends BuffCard
## Arms a one-shot Tempering condition: the next Blood Weapon this turn costs 1 less AP
## and deals +30% damage. 1 AP / 1 MP, target = SELF.

@export var condition: BattleCondition   # tempering.tres (script = TemperingCondition)


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	_activate_condition(condition, targets)
