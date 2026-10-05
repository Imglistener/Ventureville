extends BuffCard

@export var block_per_turn: DefensePerTurn

func _syphon_total(enemies: Array[EnemyBattlerStats]) -> int:
	var total := 0
	for enemy in enemies:
		var syphon := _find_status(enemy.ActiveEffects, BloodSyphon) as BloodSyphon
		if syphon:
			total += syphon.current_duration
	return total

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var amount := _syphon_total(_resolve_enemies(targets))
	if amount == 0:
		return
	var effect := block_per_turn.duplicate() as DefensePerTurn
	effect.use_duration = true
	effect.set_duration(amount)
	_apply_to_self(effect, player, amount)

func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description
	var amount := _syphon_total(enemies)
	if amount == 0:
		return Description + "\n(Gain No Congealed Blood)"
	return Description + "\n(Gain %d Congealed Blood)" % amount
