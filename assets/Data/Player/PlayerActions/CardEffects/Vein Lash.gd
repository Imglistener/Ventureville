extends DebuffCard
## Apply Blood Syphon to the target: 3, or 5 if Ascendant Ritual is active.
## Card stats (1 AP / 1 MP, Common, target = ONEENEMY) are set in the .tres.

@export var blood_syphon: BloodSyphon   # assign BloodSyphon.tres
@export var base_stacks: int = 3
@export var empowered_stacks: int = 5


func _ritual_active(character: BaseBattlerStats) -> bool:
	for condition in character.BattleConditions:
		if condition is AscendantRitualCondition:
			return true
	return false


func _stacks(character: BaseBattlerStats) -> int:
	return empowered_stacks if _ritual_active(character) else base_stacks


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	# check_applicable = true: skipped while the target has Shield, same as Hemorrhage.
	_apply_status(blood_syphon, targets, _stacks(player.Player), true)


func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description
	if enemies[0].current_block > 0:
		return Description + "\n(Target has Shield: no Blood Syphon applied)"
	if _ritual_active(character):
		return Description + "\n(Empowered: Apply %d Blood Syphon)" % empowered_stacks
	return Description + "\n(Apply %d Blood Syphon)" % base_stacks
