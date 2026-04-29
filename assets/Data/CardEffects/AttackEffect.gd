class_name AttackEffect extends CardEffect

var amount = 0
var damage_type: DamageType

func activate(targets : Array[Node]) -> void:
	var player = targets[0].get_tree().get_first_node_in_group('player').Player as CharacterInstance
	if player:
		for target in targets:
			if not target:
				continue
			if target is EnemyView:
				target.Enemy.Entity.take_damage(amount, damage_type)
			elif target is Stat_Manager:
				target.Player.take_damage(amount, damage_type)
			else:
				return
