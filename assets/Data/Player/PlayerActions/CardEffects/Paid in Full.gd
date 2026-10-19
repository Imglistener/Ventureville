extends DefendCard
## Converts all your Blood Debt into the same amount of Shield. No Syphon on yourself.
## Does nothing if you have no Blood Debt.
## Card stats (2 AP / 1 MP, is_card_nullable = true) are set in the .tres.


func _debt_amount(character: BaseBattlerStats) -> int:
	var debt := _find_status(character.ActiveEffects, BloodDebt) as BloodDebt
	return debt.current_duration if debt else 0


func _execute(player: Stat_Manager, _targets: Array[Node]) -> void:
	var amount := _debt_amount(player.Player)
	if amount <= 0:
		return

	var debt := _find_status(player.Player.ActiveEffects, BloodDebt)
	debt.on_remove(player.Player)

	var self_target: Array[Node] = [player]
	var block := BlockEffect.new()
	block.amount = amount
	block.activate(self_target)

	Events.effect_applied.emit()   # refresh the status icon now that the debt is gone


func get_live_description(character: CharacterInstance, _live_targets: Array[Node]) -> String:
	var amount := _debt_amount(character)
	if amount <= 0:
		return Description + "\n(You have no Blood Debt)"
	return Description + "\n(Gain %d Shield)" % amount
