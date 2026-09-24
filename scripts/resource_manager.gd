class_name resource_manager extends Node

@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var enemy_manager: EnemyManager = $"../EnemyManager"
@onready var player_view: PlayerView = $"../../Control_Layer/Control_Base/Base_Margin/MarginContainer/PlayerView"


func _ready() -> void:
	if not player_stat_manager.is_node_ready():
		await player_stat_manager.ready
	if not player_view.is_node_ready():
		await player_view.ready

	if not player_stat_manager.EntityStatsChanged.is_connected(_on_signal_StatsChanged):
		player_stat_manager.EntityStatsChanged.connect(_on_signal_StatsChanged)

	enemy_manager.connect_and_catch_up(_on_enemy_registered)
	Events.EnemyBattleEnd.connect(player_increment_mana.unbind(1))

func _on_enemy_registered(view: EnemyView, stat_manager: Stat_Manager) -> void:
	if not stat_manager.EntityStatsChanged.is_connected(_on_signal_StatsChanged):
		stat_manager.EntityStatsChanged.connect(_on_signal_StatsChanged)


func player_increment_mana() -> void:
	if not player_stat_manager.Entity is CharacterInstance:
		return
	player_stat_manager.Player.max_mana += 1
	player_stat_manager.Player.mana = player_stat_manager.Player.max_mana
	player_stat_manager.Player.AP = 3




func _on_signal_StatsChanged(view: EnemyView, stat_manager: Stat_Manager) -> void:
	if view != null:
		_update_enemy_bars(view, stat_manager)
	else:
		_update_player_bars(stat_manager)


func _update_enemy_bars(view: EnemyView, stat_manager: Stat_Manager) -> void:
	var entity := stat_manager.Entity

	# Enemy Health
	if view.enemy_hp.value != entity.current_health:
		view.enemy_hp.change_value(entity.current_health)
		view.enemy_bars_container.set_enemy_health_label(entity.current_health)

	# Enemy Sanity
	if view.enemy_san.value != entity.current_sanity:
		view.enemy_san.change_value(entity.current_sanity)
		view.enemy_bars_container.set_enemy_san_label(entity.current_sanity)

	# Enemy Shield (Physical Block)
	if view.enemy_shield.value != entity.current_block:
		if entity.current_block == 0:
			view.enemy_shield.max_value = entity.current_block + 1
		if view.enemy_shield.max_value < entity.current_block:
			view.enemy_shield.max_value = entity.current_block
		view.enemy_shield.change_value(entity.current_block)
		view.enemy_bars_container.set_enemy_block_label(entity.current_block)

	# Enemy Sanity Shield
	if view.enemy_san_shield.value != entity.current_san_block:
		if entity.current_san_block == 0:
			view.enemy_san_shield.max_value = entity.current_san_block + 1
		if view.enemy_san_shield.max_value < entity.current_san_block:
			view.enemy_san_shield.max_value = entity.current_san_block
		view.enemy_san_shield.change_value(entity.current_san_block)
		view.enemy_bars_container.set_enemy_san_block_label(entity.current_san_block)



func _update_player_bars(stat_manager: Stat_Manager) -> void:
	await get_tree().process_frame
	
	var bars := player_view.player_bars_container
	var player := stat_manager.Player

	# Player Health
	if bars.player_hp.value != player.current_health:
		bars.player_hp.change_value(player.current_health)
		player_view.player_bars_container.set_player_health_label(player.current_health)

	# Player Sanity
	if bars.player_san.value != player.current_sanity:
		bars.player_san.change_value(player.current_sanity)
		player_view.player_bars_container.set_player_san_label(player.current_sanity)

	# Player Shield (Physical Block)
	if bars.player_shield.value != player.current_block:
		if player.current_block == 0:
			player_view.player_bars_container.player_shield.max_value = player.current_block + 1
		if player_view.player_bars_container.player_shield.max_value < player.current_block:
			player_view.player_bars_container.player_shield.max_value = player.current_block
		bars.player_shield.change_value(player.current_block)
		player_view.player_bars_container.set_player_block_label(player.current_block)

	# Player Sanity Shield
	if bars.player_san_shield.value != player.current_san_block:
		if player.current_block == 0:
			player_view.player_bars_container.player_san_shield.max_value = player.current_san_block + 1
		if player_view.player_bars_container.player_san_shield.max_value < player.current_san_block:
			player_view.player_bars_container.player_san_shield.max_value = player.current_san_block
		bars.player_san_shield.change_value(player.current_san_block)
		player_view.player_bars_container.set_player_san_block_label(player.current_san_block)
