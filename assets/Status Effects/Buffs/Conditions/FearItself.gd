class_name FearItselfCondition
extends VoiceCondition
## The first time each turn an enemy becomes Horrified, gain 1 MP. The label shows what is left.

@export var mp_gain: int = 1

var _used_this_turn := false


func _on_attach() -> void:
	Events.status_applied.connect(_on_status_applied)
	Events.PlayerStandbyStart.connect(_on_player_standby)


func get_display_text() -> String:
	return "0" if _used_this_turn else str(mp_gain)


func _on_status_applied(status: StatusEffect, entity: BaseBattlerStats) -> void:
	if not _is_active():
		_stop_listening()
		return
	if status is not Horrified or entity == _owner or _used_this_turn:
		return
	_used_this_turn = true
	_owner.mana += mp_gain
	Events.effect_applied.emit()


func _on_player_standby(_phase: Variant = null) -> void:
	if not _is_active():
		_stop_listening()
		return
	if _used_this_turn:
		_used_this_turn = false
		Events.effect_applied.emit()


func _stop_listening() -> void:
	if Events.status_applied.is_connected(_on_status_applied):
		Events.status_applied.disconnect(_on_status_applied)
	if Events.PlayerStandbyStart.is_connected(_on_player_standby):
		Events.PlayerStandbyStart.disconnect(_on_player_standby)


func on_expired(targets: Array[Node]) -> void:
	_stop_listening()
	super(targets)
