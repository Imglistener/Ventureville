extends DebuffCard
## Converts your Regeneration into Blood Syphon on all enemies (Regeneration is NOT consumed).
## Then: Blood Debt, or if Ascendant Ritual is active, reset its count instead.
## Use target = ALLENEMIES, tag with &"SecondRite".

@export var blood_syphon: BloodSyphon
@export var blood_debt: BloodDebt
@export var debt_amount: int = 30


func _regen_stacks(character: BaseBattlerStats) -> int:
	var regen := _find_status(character.ActiveEffects, Regeneration)
	return regen.current_duration if regen else 0


func _ritual_active(character: BaseBattlerStats) -> bool:
	for condition in character.BattleConditions:
		if condition is AscendantRitualCondition:
			return true
	return false


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var amount := _regen_stacks(player.Player)
	if amount > 0:
		_apply_to_enemies(blood_syphon, targets, amount)

	var ritual := _find_condition(player, AscendantRitualCondition) as AscendantRitualCondition
	if ritual:
		ritual.reset_count()
		Events.effect_applied.emit()
	else:
		_apply_to_self(blood_debt, player, debt_amount)


## Shows the Syphon you will apply AND which branch (Debt vs Ritual reset) will happen.
func get_live_description(character: CharacterInstance, _live_targets: Array[Node]) -> String:
	var text := Description + "\n(Apply %d Blood Syphon to each enemy)" % _regen_stacks(character)
	if _ritual_active(character):
		return text + "\n(Reset Ascendant Ritual's count)"
	return text + "\n(Gain %d Blood Debt)" % debt_amount
