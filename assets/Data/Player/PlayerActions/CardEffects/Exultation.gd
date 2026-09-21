extends Card

@export var blood_tax : int
@export var blood_syphon: BloodSyphon
@export var regenaration: Regeneration

func apply_effect(targets : Array[Node]) -> void:
	var player = targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	
	var player_regen := regenaration.find_same_effect(player.Player.ActiveEffects)
	var amount := 0
	var enemy_targets: Array[Node]
	
	if player_regen:
		amount = player_regen.current_duration
		player_regen.on_remove(player.Player)
		player.Player.current_health = player.Player.Max_HP/2
		var blood_syphon_effect = blood_syphon.duplicate()
		for t in targets:
			if t is EnemyView:
				enemy_targets.append(t)
		for i in range(amount):
			blood_syphon_effect.on_apply(enemy_targets)
		
