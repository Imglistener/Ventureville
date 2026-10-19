extends DebuffCard
## Doubles the Blood Syphon on the target enemy.
## Card stats (1 AP / 3 MP, is_card_nullable = true, target = ONEENEMY) are set in the .tres.

@export var blood_syphon: BloodSyphon
@export var multiplier: int = 2


func _syphon_stacks(entity: BaseBattlerStats) -> int:
	var syphon := _find_status(entity.ActiveEffects, BloodSyphon) as BloodSyphon
	return syphon.current_duration if syphon else 0


func _execute(_player: Stat_Manager, targets: Array[Node]) -> void:
	var target := targets[0] as EnemyView
	if not target or not target.Enemy or not target.Enemy.Entity:
		return
	var stacks := _syphon_stacks(target.Enemy.Entity)
	if stacks <= 0:
		return
	# on_apply adds to the existing stack, so applying (multiplier - 1) x stacks doubles it.
	_apply_status(blood_syphon, targets, stacks * (multiplier - 1))


func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description
	var stacks := _syphon_stacks(enemies[0])
	if stacks <= 0:
		return Description + "\n(Target has no Blood Syphon)"
	return Description + "\n(Blood Syphon: %d -> %d)" % [stacks, stacks * multiplier]
