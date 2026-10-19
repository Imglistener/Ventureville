extends BuffCard
## Draw cards and gain MP, then take on Blood Debt.
## Card stats (1 AP / 1 MP) are set in the .tres.

@export var blood_debt: BloodDebt
@export var draw_amount: int = 2
@export var mp_gained: int = 3
@export var debt_amount: int = 30


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	_draw_cards(targets, draw_amount)
	_gain_mp(targets, mp_gained)
	_apply_to_self(blood_debt, player, debt_amount)
