extends DefendCard
## SAN Shield (BaseSanShield in the data) and Retain 1.

@export var retain_effect: RetainHand      # Retain.tres


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_gain_block(targets)
	_apply_to_self(retain_effect, player, 1)
