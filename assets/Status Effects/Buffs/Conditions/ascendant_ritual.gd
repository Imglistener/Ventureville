extends Battle_Condition

@export var blood_effect : StatusEffect
@export var amount_applied: int

func on_tick(targets : Array[Node]) -> void:
	for target in targets:
		if target is EnemyView:
			for multiplier in range(amount_applied):
				var applied_effect = blood_effect.duplicate() as BloodSyphon
				applied_effect.on_apply([target])
				
func activate(targets: Array[Node]) -> void:
	var player = targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	if find_same_effect(player.Player.BattleConditions):
		return
	var activated_condition = self.duplicate()
	player.Player.BattleConditions.append(activated_condition)
	Events.BattleConditionActivated.emit(activated_condition, player.Player)
