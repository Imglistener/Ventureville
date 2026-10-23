extends VoiceAttackCard
## Psychic hit, doubled against a Concussed or Stunned target.

@export var multiplier: float = 2.0


func _controlled(entity: BaseBattlerStats) -> bool:
	return entity != null and (entity.is_concussed() or entity.is_stunned())


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	var total := _calculate_total(player.Player)
	if _controlled(_entity_of(targets[0])):
		total = int(total * multiplier)
	_deal_damage(targets, total)


func _preview_value(character: CharacterInstance, enemy: EnemyBattlerStats, apply_resistance: bool) -> int:
	var total := _calculate_total(character)
	if _controlled(enemy):
		total = int(total * multiplier)
	return enemy.calculate_type_adjusted_damage(total, damage_type) if apply_resistance else total
