extends Card
@export var damage_type: DamageType
func apply_effect(targets : Array[Node]) -> void:
	if targets.is_empty():
		return
	var tree = targets[0].get_tree()
	var player := tree.get_first_node_in_group('player') as Stat_Manager
	if not player:
		return
	for enemy in targets:
		if enemy is EnemyView:
			for effect in enemy.Enemy.Entity.ActiveEffects:
				if effect is BloodSyphon:
					enemy.Enemy.Entity.take_damage(effect.current_duration + player.Player.get_attack_bonus(), damage_type)
					return
			enemy.Enemy.Entity.take_damage(player.Player.get_attack_bonus())
