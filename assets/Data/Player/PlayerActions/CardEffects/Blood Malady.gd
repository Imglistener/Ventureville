extends Card
@export var damage_type: DamageType
@export var blood_tax : int
func apply_effect(targets : Array[Node]) -> void:
	if targets.is_empty():
		return
	var tree = targets[0].get_tree()
	var player := tree.get_first_node_in_group('player') as Stat_Manager
	if not player:
		return
	player.Player.true_take_damage(blood_tax)
	for enemy in targets:
		if enemy is EnemyView:
			for effect in enemy.Enemy.Entity.ActiveEffects:
				if effect is BloodSyphon:
					for multiplier in range(2):
						enemy.Enemy.Entity.take_damage(effect.current_duration + player.Player.get_attack_bonus(), damage_type)
					return
			enemy.Enemy.Entity.take_damage(player.Player.get_attack_bonus())
