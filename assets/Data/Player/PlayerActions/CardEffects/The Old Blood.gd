extends DefendCard
## Converts all your Blood Debt into the same amount of Shield and Blood Syphon (on yourself).
## Does nothing if you have no Blood Debt.

@export var blood_syphon: BloodSyphon


func _debt_amount(character: BaseBattlerStats) -> int:
	var debt := _find_status(character.ActiveEffects, BloodDebt) as BloodDebt
	return debt.current_duration if debt else 0


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var amount := _debt_amount(player.Player)
	if amount <= 0:
		return

	var debt := _find_status(player.Player.ActiveEffects, BloodDebt)
	debt.on_remove(player.Player)

	var self_target: Array[Node] = [player]
	var block := BlockEffect.new()
	block.amount = amount
	block.activate(self_target)

	_apply_to_self(blood_syphon, player, amount)
	Events.effect_applied.emit()


func get_live_description(character: CharacterInstance, _live_targets: Array[Node]) -> String:
	var amount := _debt_amount(character)
	if amount <= 0:
		return Description + "\n(You have no Blood Debt)"
	return Description + "\n(Gain %d Shield and Blood Syphon)" % amount
