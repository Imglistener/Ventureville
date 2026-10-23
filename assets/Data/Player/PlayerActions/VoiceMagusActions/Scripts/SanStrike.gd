extends VoiceAttackCard
## SAN-only damage, no HP, ignores resistance.
## Banshee's Wail: san_multiplier 1.0, target ALLENEMIES (base 10 -> 20 at Influence 15).
## Night Terror:   san_multiplier 3.0, target ONEENEMY.

@export var san_multiplier: float = 1.0


func _calculate_total(character: CharacterInstance) -> int:
	return int(super(character) * san_multiplier)


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var enemies: Array[Node] = []
	for t in targets:
		if t is EnemyView:
			enemies.append(t)
	if enemies.is_empty():
		return
	var effect := SanAttackEffect.new()
	effect.amount = int(_calculate_total(player.Player) * _orchestrate_mult())
	effect.activate(enemies)


# No resistance icons or HP preview: this card never touches HP.
func get_live_description(character: CharacterInstance, _live_targets: Array[Node]) -> String:
	return get_description(character)
