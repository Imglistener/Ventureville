extends DebuffCard
## Stage Fright (stacks = 2), Unsettle (stacks = 1, low_sanity_fraction = 0.5, low_sanity_stacks = 2).
## Haunt later: same script with target = ALLENEMIES, stacks = 1.

@export var horrified: Horrified
@export var stacks: int = 2
## 0 disables the bonus. 0.5 = bonus while the target is below 50% SAN.
@export_range(0.0, 1.0) var low_sanity_fraction: float = 0.0
@export var low_sanity_stacks: int = 2


func _stacks_for(entity: BaseBattlerStats) -> int:
	if low_sanity_fraction > 0.0 and entity and entity.current_sanity < entity.Max_SAN * low_sanity_fraction:
		return low_sanity_stacks
	return stacks


func _execute(_player: Stat_Manager, targets: Array[Node]) -> void:
	if not horrified:
		return
	for t in targets:
		if t is EnemyView:
			var single: Array[Node] = [t]
			_apply_status(horrified, single, _stacks_for(_entity_of(t)))


func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty() or not horrified:
		return Description
	return Description + "\n(Apply %d Horrified)" % _stacks_for(enemies[0])
