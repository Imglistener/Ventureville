extends VoiceAttackCard
## Psychic hit plus 3 per Horrified stack on the target. Stacks are kept.

@export var per_stack: int = 3


func _stacks(entity: BaseBattlerStats) -> int:
	var h := entity.get_status(Horrified) if entity else null
	return h.current_duration if h else 0


func _total(character: CharacterInstance, stacks: int) -> int:
	return int((base_damage + _stat_bonus(character) + per_stack * stacks) * character.get_attack_bonus())


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	_deal_damage(targets, _total(player.Player, _stacks(_entity_of(targets[0]))))


func _preview_value(character: CharacterInstance, enemy: EnemyBattlerStats, apply_resistance: bool) -> int:
	var total := _total(character, _stacks(enemy))
	return enemy.calculate_type_adjusted_damage(total, damage_type) if apply_resistance else total
