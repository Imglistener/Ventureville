extends Card
@export var blood_tax : int
@export var block_per_turn: DefensePerTurn
@export var blood_syphon : BloodSyphon



func apply_effect(targets : Array[Node]) -> void:
	var player: Stat_Manager = targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	var playerarray: Array[Node] = [player]
	if not player:
		return
	var amount_gained : int = 0
	for enemy in targets:
		if enemy is EnemyView:
				var same_effect := blood_syphon.find_same_effect(enemy.Enemy.Entity.ActiveEffects)
				if same_effect:
					amount_gained += same_effect.current_duration
	if amount_gained == 0:
		return
	var bpt := block_per_turn.duplicate()
	bpt.use_duration = true
	bpt.set_duration(amount_gained)
	bpt.on_apply(playerarray, bpt.current_duration)
	
func _resolve_enemies(live_targets: Array[Node]) -> Array[EnemyBattlerStats]:
	var enemies: Array[EnemyBattlerStats] = []
	for t in live_targets:
		var entity := _resolve_enemy_entity(t)
		if entity:
			enemies.append(entity)
	return enemies
	
func _resolve_enemy_entity(node: Node) -> EnemyBattlerStats:
	var current := node
	while current:
		if current is EnemyView:
			return current.Enemy.Entity as EnemyBattlerStats
		current = current.get_parent()
	return null

func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description
	var amount_gained : int
	for enemy in enemies:
		var same_effect := blood_syphon.find_same_effect(enemy.ActiveEffects)
		if same_effect:
			amount_gained += same_effect.current_duration
	if amount_gained == 0:
		return Description + "\n(Gain No Congealed Blood)"
	return Description + "\n(Gain %d Congealed Blood)" % amount_gained
