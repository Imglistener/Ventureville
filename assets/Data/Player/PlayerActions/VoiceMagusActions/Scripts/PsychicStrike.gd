extends VoiceAttackCard
## Whisper, Shriek (san_ratio_override = 1.0), Chorus (target = ALLENEMIES).

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	_deal_damage(targets, _calculate_total(player.Player))
