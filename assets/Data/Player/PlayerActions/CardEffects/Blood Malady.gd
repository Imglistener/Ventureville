extends AttackCard

# Fixes the old bug where the no-Syphon branch ran once per unrelated status effect.

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var enemy := targets[0] as EnemyView
	if not enemy:
		return
	_pay_blood_tax(player)
	var per_hit := _hit_damage(player.Player, enemy.Enemy.Entity)
	for i in 2:
		_deal_damage(targets, per_hit)

func _hit_damage(character: CharacterInstance, entity: EnemyBattlerStats) -> int:
	var syphon := _find_status(entity.ActiveEffects, BloodSyphon) as BloodSyphon
	var base := syphon.current_duration if syphon else 0
	return base + character.get_attack_bonus()

func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description
	Events.reveal_enemy_resistances.emit(damage_type, enemies)
	var adjusted := enemies[0].calculate_type_adjusted_damage(_hit_damage(character, enemies[0]), damage_type)
	return Description + "\n(Deals %d Blood Damage)" % (adjusted * 2)
