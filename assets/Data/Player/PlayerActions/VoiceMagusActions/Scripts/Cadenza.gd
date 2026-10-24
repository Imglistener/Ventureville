extends VoiceAttackCard
## Psychic damage for every time you Orchestrated this turn (counted by TurnTrackingManager).
## Every 4th Orchestrate of the battle returns a copy from the discard pile (see TurnTrackingManager).
## {scaled} in the description is the damage PER Orchestrate (scaled / 4).
## Tag the .tres with &"Cadenza".

@export var damage_fraction: float = 0.25


func _calculate_total(character: CharacterInstance) -> int:
	return int(super(character) * damage_fraction)


func _count(tracker: TurnTrackingManager) -> int:
	return tracker.count_orchestrations_this_turn() if tracker else 0


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	var count := _count(_get_turn_tracker(player))
	if count <= 0:
		return
	_deal_damage(targets, _calculate_total(player.Player) * count)


# Cadenza doesn't orchestrate itself, so the count is the same before and after playing.
func _preview_value(character: CharacterInstance, enemy: EnemyBattlerStats, apply_resistance: bool) -> int:
	var total := _calculate_total(character) * _count(_tracker())
	return enemy.calculate_type_adjusted_damage(total, damage_type) if apply_resistance else total


func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var n := _count(_tracker())
	return super(character, live_targets) + "\n(Orchestrated %d time%s this turn)" % [n, "" if n == 1 else "s"]
