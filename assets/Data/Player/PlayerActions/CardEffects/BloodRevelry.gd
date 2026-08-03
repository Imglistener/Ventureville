extends Card

var healing : int
var damage_gained: int

func apply_effect(targets : Array[Node]) -> void:
	var tree = targets[0].get_tree()
	var enemy = targets[0].Enemy.Entity as EnemyBattlerStats
	var player = tree.get_first_node_in_group('player').Player as CharacterInstance
	for effect in enemy.ActiveEffects:
		if effect is BloodSyphon:
			healing = effect.current_duration * 3
			damage_gained = effect.current_duration
			effect.on_remove(enemy)
			player.heal(healing)
			player.san_heal(healing)
			var applied_effect = DamageUP.new()
			applied_effect.amount = damage_gained
			applied_effect.current_duration = 1
			applied_effect.on_apply([tree.get_first_node_in_group('player')])
		
