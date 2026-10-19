extends AttackCard
## Damage = your current Blood Debt, then the debt is reduced by one step (10).
## Debt lives in BloodDebt.current_duration. {scaled} in the description and the
## live preview show the debt that will be converted into damage.


func _debt_amount(character: BaseBattlerStats) -> int:
	var debt := _find_status(character.ActiveEffects, BloodDebt) as BloodDebt
	return debt.current_duration if debt else 0


## Used by get_description() and the live preview (via _preview_value).
func _calculate_total(character: CharacterInstance) -> int:
	if not character:
		return 0
	return int(_debt_amount(character) * character.get_attack_bonus())


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	var character := player.Player

	# Read the debt BEFORE reducing it, so this hit uses the full amount.
	var damage := _calculate_total(character)
	_deal_damage(targets, damage)

	var debt := _find_status(character.ActiveEffects, BloodDebt) as BloodDebt
	if debt:
		debt.current_duration = maxi(debt.current_duration - BloodDebt.DEBT_STEP, 0)
		if debt.current_duration <= 0:
			debt.on_remove(character)
		Events.effect_applied.emit()   # refresh the status icon / number

func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description
	Events.reveal_enemy_resistances.emit(damage_type, enemies)
	return Description + "\n(Deals %d Blood Damage)" % (_calculate_total(character))
