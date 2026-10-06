extends DebuffCard

@export var AppliedEffect: BloodSyphon   # BloodSyphon.tres
@export var syphon_amount: int = 5

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	# Skipped while the target has block (BloodSyphon.is_applicable), same as the other Syphon cards.
	_apply_status(AppliedEffect, targets, syphon_amount, true)

	var target := targets[0] as EnemyView
	if target and target.Enemy and target.Enemy.Entity:
		_trigger_blood_syphon(target.Enemy.Entity)

func _projected_damage(entity: EnemyBattlerStats) -> int:
	if entity.current_block > 0:
		return 0
	var existing := _find_status(entity.ActiveEffects, BloodSyphon) as BloodSyphon
	var stacks := (existing.current_duration if existing else 0) + syphon_amount
	return entity.calculate_type_adjusted_damage(2 * stacks, AppliedEffect.damage_type)

func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty() or not AppliedEffect:
		return Description

	var entity := enemies[0]
	if entity.get_resistance_state(AppliedEffect.damage_type) == EnemyBattlerStats.RESISTANCE_STATE.NEUTRAL:
		Events.hide_enemy_resistances.emit()
	else:
		Events.reveal_enemy_resistances.emit(AppliedEffect.damage_type, enemies)

	if entity.current_block > 0:
		return Description + "\n(Target is blocking: no Blood Syphon applied)"
	return Description + "\n(Deals %d Blood Damage)" % _projected_damage(entity)
