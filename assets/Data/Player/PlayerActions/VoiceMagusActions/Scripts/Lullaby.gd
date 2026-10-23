extends DebuffCard
## Stuns the target if it has enough Horrified. Otherwise nothing happens.

@export var required_stacks: int = 5
@export var stun_duration: int = 1


func _stacks(entity: BaseBattlerStats) -> int:
	var h := entity.get_status(Horrified) if entity else null
	return h.current_duration if h else 0


func _execute(_player: Stat_Manager, targets: Array[Node]) -> void:
	for t in targets:
		if t is EnemyView and _stacks(_entity_of(t)) >= required_stacks:
			var single: Array[Node] = [t]
			Stunned.new().on_apply(single, stun_duration)
			return


func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description
	var stacks := _stacks(enemies[0])
	if stacks >= required_stacks:
		return Description + "\n(Stuns the target)"
	return Description + "\n(Needs %d Horrified, target has %d)" % [required_stacks, stacks]
