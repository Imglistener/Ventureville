class_name CollectiveDreadCondition
extends VoiceCondition
## When an enemy gains Horrified, every other enemy gains 1 (once per turn).

const HORRIFIED_RES := preload("res://assets/Status Effects/Debuffs/Horrified.tres")

@export var spread_stacks: int = 1

var _used_this_turn := false
var _busy := false   # applying Horrified fires status_applied again


func _on_attach() -> void:
	Events.status_applied.connect(_on_status_applied)
	Events.PlayerStandbyStart.connect(_on_player_standby)


func _on_status_applied(status: StatusEffect, entity: BaseBattlerStats) -> void:
	if not _is_active():
		_stop_listening()
		return
	if status is not Horrified or entity == _owner or _busy or _used_this_turn:
		return
	var manager := _player.get_tree().get_first_node_in_group("EnemyManager") as EnemyManager
	if not manager:
		return
	_used_this_turn = true
	_busy = true
	for view in manager.get_enemy_views():
		var sm := manager.get_stat_manager_for(view)
		if sm and sm.Entity != entity:
			var targets: Array[Node] = [view]
			HORRIFIED_RES.on_apply(targets, spread_stacks)
	_busy = false


func _on_player_standby(_phase: Variant = null) -> void:
	if not _is_active():
		_stop_listening()
		return
	_used_this_turn = false


func _stop_listening() -> void:
	if Events.status_applied.is_connected(_on_status_applied):
		Events.status_applied.disconnect(_on_status_applied)
	if Events.PlayerStandbyStart.is_connected(_on_player_standby):
		Events.PlayerStandbyStart.disconnect(_on_player_standby)


func on_expired(targets: Array[Node]) -> void:
	_stop_listening()
	super(targets)
