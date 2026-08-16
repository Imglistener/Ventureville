class_name resource_manager extends Node

@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var enemy_manager: EnemyManager = $"../EnemyManager"
@onready var player_view: PlayerView = $"../../Control_Layer/Control_Base/Base_Margin/MarginContainer/PlayerView"


func _ready() -> void:
	if not player_stat_manager.is_node_ready():
		await player_stat_manager.ready
	if not player_view.is_node_ready():
		await player_view.ready

	player_view.player_bars_container.player_hp_counter.label_settings = \
		player_view.player_bars_container.player_hp_counter.label_settings.duplicate()
	player_view.player_bars_container.player_san_counter.label_settings = \
		player_view.player_bars_container.player_san_counter.label_settings.duplicate()

	if not player_stat_manager.EntityStatsChanged.is_connected(_on_signal_StatsChanged):
		player_stat_manager.EntityStatsChanged.connect(_on_signal_StatsChanged)

	enemy_manager.connect_and_catch_up(_on_enemy_registered)
	Events.EnemyBattleEnd.connect(player_increment_mana.unbind(1))

func _on_enemy_registered(view: EnemyView, stat_manager: Stat_Manager) -> void:
	view.enemy_hp_counter.label_settings = view.enemy_hp_counter.label_settings.duplicate()
	view.enemy_san_counter.label_settings = view.enemy_san_counter.label_settings.duplicate()

	if not stat_manager.EntityStatsChanged.is_connected(_on_signal_StatsChanged):
		stat_manager.EntityStatsChanged.connect(_on_signal_StatsChanged)


func player_increment_mana() -> void:
	if not player_stat_manager.Entity is CharacterInstance:
		return
	player_stat_manager.Player.max_mana += 1
	player_stat_manager.Player.mana = player_stat_manager.Player.max_mana
	player_stat_manager.Player.AP = 3


func _set_counter_label(label: Label, health_value: int, block_value: int, base_font_size: int = 30) -> void:
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if block_value > 0:
		label.text = str(block_value)
		label.label_settings.font_color = Color(0.5, 0.85, 1.0)   # Light blue
		label.label_settings.font_size = base_font_size + 4        # Slightly larger
	else:
		label.text = str(health_value)
		label.label_settings.font_color = Color.WHITE
		label.label_settings.font_size = base_font_size


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
		_set_counter_label(view.enemy_hp_counter, entity.current_health, entity.current_block)

	# Enemy Sanity
	if view.enemy_san.value != entity.current_sanity:
		view.enemy_san.change_value(entity.current_sanity)
		_set_counter_label(view.enemy_san_counter, entity.current_sanity, entity.current_san_block)

	# Enemy Shield (Physical Block)
	if view.enemy_shield.value != entity.current_block:
		view.enemy_shield.change_value(entity.current_block)
		_set_counter_label(view.enemy_hp_counter, entity.current_health, entity.current_block)

	# Enemy Sanity Shield
	if view.enemy_san_shield.value != entity.current_san_block:
		view.enemy_san_shield.change_value(entity.current_san_block)
		_set_counter_label(view.enemy_san_counter, entity.current_sanity, entity.current_san_block)


func _update_player_bars(stat_manager: Stat_Manager) -> void:
	var bars := player_view.player_bars_container
	var player := stat_manager.Player

	# Player Health
	if bars.player_hp.value != player.current_health:
		bars.player_hp.change_value(player.current_health)
		_set_counter_label(bars.player_hp_counter, player.current_health, player.current_block)

	# Player Sanity
	if bars.player_san.value != player.current_sanity:
		bars.player_san.change_value(player.current_sanity)
		bars.player_san_counter.text = str(player.current_sanity)

	# Player Shield (Physical Block)
	if bars.player_shield.value != player.current_block:
		bars.player_shield.change_value(player.current_block)
		_set_counter_label(bars.player_hp_counter, player.current_health, player.current_block)

	# Player Sanity Shield
	if bars.player_san_shield.value != player.current_san_block:
		bars.player_san_shield.change_value(player.current_san_block)
		_set_counter_label(bars.player_san_counter, player.current_sanity, player.current_san_block)
