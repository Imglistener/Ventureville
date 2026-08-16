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
	player_stat_manager.Player.reset_AP()
	

func _set_counter_label(label: Label, health_value: int, block_value: int, base_font_size: int = 30) -> void:
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if block_value > 0:
		label.text = str(block_value)
		label.label_settings.font_color = Color(0.5, 0.85, 1.0)
		label.label_settings.font_size = base_font_size + 4
	else:
		label.text = str(health_value)
		label.label_settings.font_color = Color.WHITE
		label.label_settings.font_size = base_font_size

func _on_signal_StatsChanged() -> void:
	var e_bars := enemy
	var p_bars := player_view.player_bars_container

	# Enemy Health
	if e_bars.enemy_hp.value != enemy_stat_manager.Entity.current_health:
		e_bars.enemy_hp.max_value = max(e_bars.enemy_hp.max_value, enemy_stat_manager.Entity.current_health)
		e_bars.enemy_hp.change_value(enemy_stat_manager.Entity.current_health)
		_set_counter_label(e_bars.enemy_hp_counter,
			enemy_stat_manager.Entity.current_health,
			enemy_stat_manager.Entity.current_block)

	# Enemy Sanity
	if e_bars.enemy_san.value != enemy_stat_manager.Entity.current_sanity:
		e_bars.enemy_san.max_value = max(e_bars.enemy_san.max_value, enemy_stat_manager.Entity.current_sanity)
		e_bars.enemy_san.change_value(enemy_stat_manager.Entity.current_sanity)
		_set_counter_label(e_bars.enemy_san_counter,
			enemy_stat_manager.Entity.current_sanity,
			enemy_stat_manager.Entity.current_san_block)

	# Enemy Shield
	if e_bars.enemy_shield.value != enemy_stat_manager.Entity.current_block:
		e_bars.enemy_shield.change_value(enemy_stat_manager.Entity.current_block)
		_set_counter_label(e_bars.enemy_hp_counter,
			enemy_stat_manager.Entity.current_health,
			enemy_stat_manager.Entity.current_block)

	# Enemy Sanity Shield
	if e_bars.enemy_san_shield.value != enemy_stat_manager.Entity.current_san_block:
		e_bars.enemy_san_shield.change_value(enemy_stat_manager.Entity.current_san_block)
		_set_counter_label(e_bars.enemy_san_counter,
			enemy_stat_manager.Entity.current_sanity,
			enemy_stat_manager.Entity.current_san_block)

	# Player Health
	if p_bars.player_hp.value != player_stat_manager.Player.current_health:
		p_bars.player_hp.max_value = max(p_bars.player_hp.max_value, player_stat_manager.Player.current_health)
		p_bars.player_hp.change_value(player_stat_manager.Player.current_health)
		_set_counter_label(p_bars.player_hp_counter,
			player_stat_manager.Player.current_health,
			player_stat_manager.Player.current_block)

	# Player Sanity
	if p_bars.player_san.value != player_stat_manager.Player.current_sanity:
		p_bars.player_san.max_value = max(p_bars.player_san.max_value, player_stat_manager.Player.current_sanity)
		p_bars.player_san.change_value(player_stat_manager.Player.current_sanity)
		p_bars.player_san_counter.text = str(player_stat_manager.Player.current_sanity)

	# Player Shield
	if p_bars.player_shield.value != player_stat_manager.Player.current_block:
		p_bars.player_shield.change_value(player_stat_manager.Player.current_block)
		_set_counter_label(p_bars.player_hp_counter,
			player_stat_manager.Player.current_health,
			player_stat_manager.Player.current_block)

	# Player Sanity Shield
	if p_bars.player_san_shield.value != player_stat_manager.Player.current_san_block:
		p_bars.player_san_shield.change_value(player_stat_manager.Player.current_san_block)
		_set_counter_label(p_bars.player_san_counter,
			player_stat_manager.Player.current_sanity,
			player_stat_manager.Player.current_san_block)

func item_usage_handler(item: Item) -> void:
	if item in player_stat_manager.Player.player_inventory.inventory.keys():
		player_stat_manager.Player.player_inventory.remove_item(item, 1)
		
