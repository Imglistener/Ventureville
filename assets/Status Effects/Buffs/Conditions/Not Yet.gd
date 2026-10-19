class_name NotYetCondition
extends BattleCondition
## Each charge saves the owner once: if HP would reach 0, it stays at 1 instead.
## When a charge is spent, Ascendant Ritual's count resets (if the Ritual is active).
## Activating it again while one is held adds a charge.

var _owner: CharacterInstance
var _player: Stat_Manager
var _charges: int = 1


func activate(targets: Array[Node]) -> void:
	var player := targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	if not player:
		return
	var existing := find_same_effect(player.Player.BattleConditions) as NotYetCondition
	if existing:
		existing._charges += 1
		Events.effect_applied.emit()   # refresh the label
		return
	var instance := self.duplicate() as NotYetCondition
	instance._owner = player.Player
	instance._player = player
	instance._charges = 1
	player.Player.BattleConditions.append(instance)
	Events.BattleConditionActivated.emit(instance, player.Player)
	Events.effect_display.emit(self, player.Player.damage_number_anchor, player.Player.damage_number_anchor.global_position)


func get_display_text() -> String:
	return str(_charges)


func prevent_death(entity: BaseBattlerStats) -> bool:
	if entity != _owner or _charges <= 0:
		return false
	_charges -= 1

	for condition in _owner.BattleConditions:
		if condition is AscendantRitualCondition:
			condition.reset_count()
			break

	var anchor := _owner.damage_number_anchor
	if anchor:
		Events.effect_display.emit(self, anchor, anchor.global_position)
	Events.effect_applied.emit()

	if _charges <= 0:
		# Deferred: we are inside the health setter, mid-damage.
		_expire.call_deferred()
	return true


func _expire() -> void:
	if _player:
		var targets: Array[Node] = [_player]
		on_expired(targets)
