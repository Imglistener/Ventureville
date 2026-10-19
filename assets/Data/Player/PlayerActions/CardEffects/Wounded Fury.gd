extends AttackCard
## Deals {scaled} damage, doubled if the player took damage last turn.
## Card stats (1 AP / 1 MP) and base_damage / StatsScaled / damage_type are set in the .tres.

@export var empowered_multiplier: float = 2.0


func _is_empowered(player: Stat_Manager) -> bool:
	if not player:
		return false
	var tracker := _get_turn_tracker(player)
	return tracker != null and tracker.took_damage_last_turn(player)


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	var total := _calculate_total(player.Player)
	if _is_empowered(player):
		total = int(total * empowered_multiplier)
	_deal_damage(targets, total)


## Same preview as a normal attack (resistance icons, {scaled}), plus the Empowered note.
func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var text := super(character, live_targets)
	if live_targets.is_empty() or not live_targets[0]:
		return text
	var player := live_targets[0].get_tree().get_first_node_in_group("player") as Stat_Manager
	if _is_empowered(player):
		return text + "\n(Empowered)"
	return text
