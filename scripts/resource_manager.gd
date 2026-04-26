class_name resource_manager extends Node

@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var enemy_stat_manager: Stat_Manager = $"../EnemyStatManager"
@onready var enemy: EnemyView = $"../../Control_Layer/Enemy"
@onready var player_view: PlayerView = $"../../Control_Layer/Control_Base/Base_Margin/MarginContainer/PlayerView"


func _ready() -> void:
	if not player_stat_manager.is_node_ready():
		await player_stat_manager.ready
	if not enemy_stat_manager.is_node_ready():
		await enemy_stat_manager.ready
	if not enemy.is_node_ready():
		await enemy.ready
	if not player_view.is_node_ready():
		await player_view.ready
	enemy.enemy_hp_counter.label_settings = enemy.enemy_hp_counter.label_settings.duplicate()
	enemy.enemy_san_counter.label_settings = enemy.enemy_san_counter.label_settings.duplicate()
	player_view.player_bars_container.player_hp_counter.label_settings = \
		player_view.player_bars_container.player_hp_counter.label_settings.duplicate()
	player_view.player_bars_container.player_san_counter.label_settings = \
		player_view.player_bars_container.player_san_counter.label_settings.duplicate()
		
	if not player_stat_manager.Player.Stats_Changed.is_connected(_on_signal_StatsChanged):
		player_stat_manager.Player.Stats_Changed.connect(_on_signal_StatsChanged)
	if not enemy_stat_manager.Entity.Stats_Changed.is_connected(_on_signal_StatsChanged):
		enemy_stat_manager.Entity.Stats_Changed.connect(_on_signal_StatsChanged)
	Events.EnemyBattleEnd.connect(player_increment_mana.unbind(1))


func player_increment_mana() -> void:
	if not player_stat_manager.Entity is CharacterInstance:
		return
	player_stat_manager.Player.max_mana += 1
	player_stat_manager.Player.mana = player_stat_manager.Player.max_mana
	player_stat_manager.Player.AP = 3

func _set_counter_label(label: Label, health_value: int, block_value: int, base_font_size: int = 30)-> void:
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if block_value > 0:
		label.text = str(block_value)
		label.label_settings.font_color = Color(0.5, 0.85, 1.0)   # Light blue
		label.label_settings.font_size = base_font_size + 4        # Slightly larger
	else:
		label.text = str(health_value)
		label.label_settings.font_color = Color.WHITE              # Or whatever your default is
		label.label_settings.font_size = base_font_size            # Restore default size

func _on_signal_StatsChanged() -> void:
	# Enemy Health
	if enemy.enemy_hp.value != enemy_stat_manager.Entity.current_health:
		enemy.enemy_hp.change_value(enemy_stat_manager.Entity.current_health)
		_set_counter_label(enemy.enemy_hp_counter,
		enemy_stat_manager.Entity.current_health,
		enemy_stat_manager.Entity.current_block)

	
	# Enemy Sanity
	if enemy.enemy_san.value != enemy_stat_manager.Entity.current_sanity:
		enemy.enemy_san.change_value(enemy_stat_manager.Entity.current_sanity)
		_set_counter_label(enemy.enemy_san_counter,
		enemy_stat_manager.Entity.current_sanity,
		enemy_stat_manager.Entity.current_san_block)
		
	
	# Enemy Shield (Physical Block)
	if enemy.enemy_shield.value != enemy_stat_manager.Entity.current_block:
		enemy.enemy_shield.change_value(enemy_stat_manager.Entity.current_block)
		_set_counter_label(enemy.enemy_hp_counter,
		enemy_stat_manager.Entity.current_health,
		enemy_stat_manager.Entity.current_block)

	
	# Enemy Sanity Shield
	if enemy.enemy_san_shield.value != enemy_stat_manager.Entity.current_san_block:
		enemy.enemy_san_shield.change_value(enemy_stat_manager.Entity.current_san_block)
		_set_counter_label(enemy.enemy_san_counter,
		enemy_stat_manager.Entity.current_sanity,
		enemy_stat_manager.Entity.current_san_block)
	# Player Health
	if player_view.player_bars_container.player_hp.value != player_stat_manager.Player.current_health:
		player_view.player_bars_container.player_hp.change_value(player_stat_manager.Player.current_health)
		_set_counter_label(player_view.player_bars_container.player_hp_counter,
		player_stat_manager.Player.current_health,
		player_stat_manager.Player.current_block)
	
	# Player Sanity
	if player_view.player_bars_container.player_san.value != player_stat_manager.Player.current_sanity:
		player_view.player_bars_container.player_san.change_value(player_stat_manager.Player.current_sanity)
		player_view.player_bars_container.player_san_counter.text = str(player_stat_manager.Player.current_sanity)
	
	# Player Shield (Physical Block)
	if player_view.player_bars_container.player_shield.value != player_stat_manager.Player.current_block:
		player_view.player_bars_container.player_shield.change_value(player_stat_manager.Player.current_block)
		_set_counter_label(player_view.player_bars_container.player_hp_counter,
		player_stat_manager.Player.current_health,
		player_stat_manager.Player.current_block)
	
	# Player Sanity Shield
	if player_view.player_bars_container.player_san_shield.value != player_stat_manager.Player.current_san_block:
		player_view.player_bars_container.player_san_shield.change_value(player_stat_manager.Player.current_san_block)
		_set_counter_label(player_view.player_bars_container.player_san_counter,
		player_stat_manager.Player.current_sanity,
		player_stat_manager.Player.current_san_block)
