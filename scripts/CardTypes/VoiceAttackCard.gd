class_name VoiceAttackCard extends AttackCard
## Base for Psychic Voice attacks. Adds the '(Also deals X SAN damage)' live-preview line.
## Subclasses that change the damage number override _preview_value() (and _calculate_total()).

func _stat_bonus(character: CharacterInstance) -> int:
	var i := character.stats.find(StatsScaled)
	return character.stats[i].stat_scaling_value if i != -1 else 0


func _san_preview(hit: int) -> int:
	var ratio := san_ratio_override if san_ratio_override >= 0.0 else AttackEffect.PSYCHIC_SAN_RATIO
	return roundi(hit * ratio)


func _first_enemy(targets: Array[Node]) -> BaseBattlerStats:
	for t in targets:
		if t is EnemyView:
			return _entity_of(t)
	return null


func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	var hit := _preview_value(character, enemies[0], false) if not enemies.is_empty() else _calculate_total(character)
	return super(character, live_targets) + "\n(Also deals %d SAN damage)" % _san_preview(hit)
