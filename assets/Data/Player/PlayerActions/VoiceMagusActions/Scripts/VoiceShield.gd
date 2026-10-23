extends DefendCard
## Sound Barrier. BaseShield and BaseSanShield come from the .tres.

func _execute(_player: Stat_Manager, targets: Array[Node]) -> void:
	_gain_block(targets)
