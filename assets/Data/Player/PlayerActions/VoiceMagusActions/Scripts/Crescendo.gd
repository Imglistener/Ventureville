extends VoiceAttackCard
## Scaled damage for every card played this turn, counting itself.
## Set count_tag (e.g. &"BloodWeapon") to count only cards with that tag; empty counts everything.

@export var count_tag: StringName = &"Orchestrate"


func _count(tracker: TurnTrackingManager, include_this_card: bool) -> int:
	if not tracker:
		return 1
	var n := tracker.count_cards_played_this_turn() if count_tag == &"Orchestrate" else tracker.count_tag_played_this_turn(count_tag)
	return maxi(n + (0 if include_this_card else 1), 1)


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	# card_played fired before _execute, so this card is already counted.
	var plays := _count(_get_turn_tracker(player), true)
	_deal_damage(targets, _calculate_total(player.Player) * plays)


# Not played yet in a preview, so add this card itself.
func _preview_value(character: CharacterInstance, enemy: EnemyBattlerStats, apply_resistance: bool) -> int:
	var total := _calculate_total(character) * _count(_tracker(), false)
	return enemy.calculate_type_adjusted_damage(total, damage_type) if apply_resistance else total
