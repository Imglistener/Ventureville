extends DefendCard

@export var shell_effect: SanguineShell
@export var shell_duration: int = 1

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	_gain_block(targets)
	_apply_to_self(shell_effect, player, shell_duration)
