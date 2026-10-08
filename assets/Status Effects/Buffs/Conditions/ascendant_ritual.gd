class_name AscendantRitualCondition
extends BattleCondition
## At the end of each PLAYER turn, applies Blood Syphon to all enemies.
## The amount doubles every player turn: amount_applied, x2, x4, x8 ...  (2, 4, 8, 16 with amount_applied = 2)

@export var blood_effect : StatusEffect
@export var amount_applied: int = 2   # amount for the FIRST application

var _turns_elapsed: int = 0           # per-instance: how many applications have happened


## What the NEXT application will apply (also what the label shows).
func get_next_amount() -> int:
	return _turns_elapsed * amount_applied 

func get_display_text() -> String:
	return str(get_next_amount())

func on_tick(targets : Array[Node]) -> void:
	var amount := get_next_amount()
	for target in targets:
		if target is EnemyView:
			var enemy_target: Array[Node] = [target]
			blood_effect.on_apply(enemy_target, amount)   # one call with the full amount (no popup spam)
	_turns_elapsed += 1

func activate(targets: Array[Node]) -> void:
	var player = targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	if find_same_effect(player.Player.BattleConditions):
		return
	var activated_condition = self.duplicate()
	player.Player.BattleConditions.append(activated_condition)
	Events.BattleConditionActivated.emit(activated_condition, player.Player)
	Events.effect_display.emit(self, player.Player.damage_number_anchor, player.Player.damage_number_anchor.global_position)
