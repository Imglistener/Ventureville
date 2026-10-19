extends BuffCard
## If Ascendant Form or Ascendant Ritual is active, gain 1 Not Yet.
## target = SELF. Costs and rarity are set in the .tres.

@export var condition: BattleCondition   # not_yet.tres (script = NotYetCondition)


func _ascendant_active(character: BaseBattlerStats) -> bool:
	for c in character.BattleConditions:
		if c is AscendantFormCondition or c is AscendantRitualCondition:
			return true
	return false


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	if _ascendant_active(player.Player):
		_activate_condition(condition, targets)


func get_live_description(character: CharacterInstance, _live_targets: Array[Node]) -> String:
	if _ascendant_active(character):
		return Description + "\n(Gain 1 Not Yet)"
	return Description + "\n(Ascendant Form or Ritual is not active)"
