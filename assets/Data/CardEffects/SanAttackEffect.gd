class_name SanAttackEffect extends CardEffect

var amount = 0

func activate(targets : Array[Node]) -> void:
	var player = targets[0].get_tree().get_first_node_in_group('player').Player as CharacterInstance
	if player:
		for target in targets:
			if not target:
				continue
			if target is EnemyView:
				target.Enemy.Entity.take_san_damage(amount)
			elif target is Stat_Manager:
				target.Player.take_san_damage(amount)
			else:
				return
