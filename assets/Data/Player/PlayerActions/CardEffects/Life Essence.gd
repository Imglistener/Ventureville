extends BuffCard
## Gain Regeneration: 3, or 5 if you sacrificed this turn.
## Card stats (1 AP / 1 MP, Common, target = SELF) are set in the .tres.

@export var regeneration: Regeneration   # assign Regeneration.tres
@export var base_stacks: int = 3
@export var empowered_stacks: int = 5


func _stacks(player: Stat_Manager) -> int:
	return empowered_stacks if player and _sacrificed_this_turn(player) else base_stacks


func _execute(player: Stat_Manager, _targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	_apply_to_self(regeneration, player, _stacks(player))


func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	if live_targets.is_empty() or not live_targets[0]:
		return Description
	var player := live_targets[0].get_tree().get_first_node_in_group("player") as Stat_Manager
	if player and _sacrificed_this_turn(player):
		return Description + "\n(Empowered: Gain %d Regeneration)" % empowered_stacks
	return Description + "\n(Gain %d Regeneration)" % base_stacks
