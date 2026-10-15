extends BuffCard
## Attaches Ritualistic Glee, then gives the player Blood Debt.
## The condition is attached after card_played has already fired, so this card never triggers itself.

@export var condition: BattleCondition          # ritualistic_glee.tres
@export var blood_debt: BloodDebt
@export var debt_amount: int = 20


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	_activate_condition(condition, targets)
	_apply_to_self(blood_debt, player, debt_amount)
