extends DefendCard
## Shield + SAN Shield = 2 x total Blood Syphon on all enemies.
## If Ascendant Ritual is active and First + Second Rite were both played this battle:
## remove Ascendant Ritual and gain Ascendant Form.
## Use target = ALL (like Sanguine Rose) so enemies are included in `targets`.

@export var ascendant_form: BattleCondition
@export var shield_multiplier: int = 2


func _syphon_total(enemies: Array[EnemyBattlerStats]) -> int:
	var total := 0
	for enemy in enemies:
		var syphon := _find_status(enemy.ActiveEffects, BloodSyphon) as BloodSyphon
		if syphon:
			total += syphon.current_duration
	return total


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var amount := _syphon_total(_resolve_enemies(targets)) * shield_multiplier
	var self_target: Array[Node] = [player]

	if amount > 0:
		var block := BlockEffect.new()
		block.amount = amount
		block.activate(self_target)
		var san_block := SanBlockEffect.new()
		san_block.amount = amount
		san_block.activate(self_target)

	_try_ascend(player, self_target)


func _try_ascend(player: Stat_Manager, self_target: Array[Node]) -> void:
	if not ascendant_form:
		return
	var ritual := _find_condition(player, AscendantRitualCondition)
	if not ritual:
		return
	var tracker := _get_turn_tracker(player)
	if not tracker:
		return
	if not tracker.played_tag_this_battle(TAG_FIRST_RITE) or not tracker.played_tag_this_battle(TAG_SECOND_RITE):
		return
	ritual.on_expired(self_target)
	ascendant_form.activate(self_target)


func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description
	return Description + "\n(Gain %d Shield and SAN Shield)" % (_syphon_total(enemies) * shield_multiplier)
