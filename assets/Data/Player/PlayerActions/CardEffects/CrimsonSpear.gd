extends AttackCard

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	_deal_damage(targets, _calculate_total(player.Player))

	var target := targets[0] as EnemyView
	if target and target.Enemy and target.Enemy.Entity:
		var syphon := _find_status(target.Enemy.Entity.ActiveEffects, BloodSyphon) as BloodSyphon
		if syphon:
			_deal_damage(targets, syphon.current_duration)

func _preview_value(character: CharacterInstance, enemy: EnemyBattlerStats, apply_resistance: bool) -> int:
	var shown := super(character, enemy, apply_resistance)
	var syphon := _find_status(enemy.ActiveEffects, BloodSyphon) as BloodSyphon
	if syphon:
		var extra := syphon.current_duration
		shown += enemy.calculate_type_adjusted_damage(extra, damage_type) if apply_resistance else extra
	return shown
