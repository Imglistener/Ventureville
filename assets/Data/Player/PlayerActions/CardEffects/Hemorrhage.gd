extends AttackCard

@export var base_syphon_amount: int
@export var bonus_syphon_amount: int
@export var AppliedEffect: StatusEffect



func _syphon_amount_for(entity: EnemyBattlerStats) -> int:
	var amount := base_syphon_amount
	if entity and _find_status(entity.ActiveEffects, BloodSyphon):
		amount += bonus_syphon_amount
	return amount

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	_deal_damage(targets, base_damage)

	var target := targets[0] as EnemyView
	var entity: EnemyBattlerStats = null
	if target and target.Enemy and target.Enemy.Entity:
		entity = target.Enemy.Entity
	_apply_status(AppliedEffect, targets, _syphon_amount_for(entity), true)

func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description

	var entity := enemies[0]
	if entity.get_resistance_state(damage_type) == EnemyBattlerStats.RESISTANCE_STATE.NEUTRAL:
		Events.hide_enemy_resistances.emit()
	else:
		Events.reveal_enemy_resistances.emit(damage_type, enemies)
	var shown := _preview_value(character, entity, true)
	return Description + "\n(Deals %d Blood Damage) (Inflicts %d Blood Syphon)" % [shown, _syphon_amount_for(entity)]
