class_name VoiceCondition
extends BattleCondition
## Shared plumbing for the Voice conditions: attach to the player once, then call _on_attach()
## on the live instance so it can connect its own signals.

var _owner: CharacterInstance
var _player: Stat_Manager


func activate(targets: Array[Node]) -> void:
	var player := targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	if not player or find_same_effect(player.Player.BattleConditions):
		return
	var instance := self.duplicate() as VoiceCondition
	instance._owner = player.Player
	instance._player = player
	player.Player.BattleConditions.append(instance)
	instance._on_attach()
	Events.BattleConditionActivated.emit(instance, player.Player)
	var anchor := player.Player.damage_number_anchor
	if anchor:
		Events.effect_display.emit(instance, anchor, anchor.global_position)


func _on_attach() -> void:
	pass


func _is_active() -> bool:
	return _owner != null and _owner.BattleConditions.has(self)
