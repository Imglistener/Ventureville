extends Card

@export var blood_tax: int
@export var condition : Battle_Condition

func apply_effect(targets: Array[Node]) -> void:
	if targets.is_empty() or not targets[0]:
		return
	var player := targets[0] as Stat_Manager
	if not player:
		return
	player.Player.true_take_damage(blood_tax)
	condition.activate(targets)
