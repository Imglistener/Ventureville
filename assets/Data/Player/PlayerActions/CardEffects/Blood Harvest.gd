extends AttackCard

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var total := _calculate_total(player.Player)
	_deal_damage(targets, total)
	player.Player.heal(total * 2)
