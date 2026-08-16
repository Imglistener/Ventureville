class_name EnemyTurnManager extends Node

@onready var functionality: Node = get_parent()
@onready var phase_manager: PhaseManager = $"../PhaseManager"

var _enemies_pending: int = 0

func _ready() -> void:
	Events.EnemyBattleStart.connect(_on_enemy_battle_start.unbind(1))
	Events.EnemyStandbyStart.connect(_on_enemy_standby_start.unbind(1))
	Events.EnemiesDonePlaying.connect(_on_enemies_done_playing)
	Events.EnemyActionReady.connect(_on_enemy_action_ready)
	Events.EnemyStandbyEnd.connect(phase_manager.advance_to_next_phase.unbind(1))


func _get_active_enemies() -> Array[Stat_Manager]:
	var result: Array[Stat_Manager] = []
	for child in functionality.get_children():
		if child is Stat_Manager and child.Entity is EnemyBattlerStats and child.enemy_ai:
			result.append(child)
	return result


func _on_enemy_standby_start() -> void:
	var enemies := _get_active_enemies()
	_enemies_pending = enemies.size()
	for enemy_stat_manager in enemies:
		enemy_stat_manager.update_action()


func _on_enemy_action_ready() -> void:
	_enemies_pending -= 1
	if _enemies_pending <= 0:
		phase_manager.advance_to_next_phase()


func _on_enemy_battle_start() -> void:
	await enemy_turn_order()


func enemy_turn_order() -> void:
	for enemy_stat_manager in _get_active_enemies():
		enemy_stat_manager.play_turn()
		await Events.EnemyActionCompleted
	Events.EnemiesDonePlaying.emit()


func _on_enemies_done_playing() -> void:
	await get_tree().create_timer(0.5, true, false, false).timeout
	phase_manager.advance_to_next_phase()
