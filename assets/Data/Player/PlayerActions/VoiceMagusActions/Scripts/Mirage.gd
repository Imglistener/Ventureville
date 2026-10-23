extends DefendCard
## Shield equal to 4 x the total Horrified stacks on enemies. Same targeting as Sanguine Rose
## (target = ALL, so enemies are included in `targets`).

@export var per_stack: int = 4


func _horrified_total(enemies: Array[EnemyBattlerStats]) -> int:
	var total := 0
	for e in enemies:
		var h := e.get_status(Horrified)
		if h:
			total += h.current_duration
	return total


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var amount := _horrified_total(_resolve_enemies(targets)) * per_stack
	if amount <= 0:
		return
	var self_target: Array[Node] = [player]
	var block := BlockEffect.new()
	block.amount = amount
	block.activate(self_target)


func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description
	return Description + "\n(Gain %d Shield)" % (_horrified_total(enemies) * per_stack)
