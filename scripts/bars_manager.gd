class_name Bars_Manager extends Node

@onready var Resources: resource_manager = $"../Resource Manager"

@onready var enemy_hp: TextureProgressBar = $"../../UI/BackgroundImage/Main_Container/Main_Elements/Combat_Container/MarginContainer/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/enemy_hp"
@onready var enemy_san: TextureProgressBar = $"../../UI/BackgroundImage/Main_Container/Main_Elements/Combat_Container/MarginContainer/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer/enemy_san"
@onready var player_hp: TextureProgressBar = $"../../UI/BackgroundImage/Main_Container/Main_Elements/Combat_Container/NinePatchRect/player_stats_container/VBoxContainer/player_hp"
@onready var player_san: TextureProgressBar = $"../../UI/BackgroundImage/Main_Container/Main_Elements/Combat_Container/NinePatchRect/player_stats_container/VBoxContainer/player_san"
@onready var player_shield: TextureProgressBar = $"../../UI/BackgroundImage/Main_Container/Main_Elements/Combat_Container/NinePatchRect/player_stats_container/VBoxContainer2/player_shield"
@onready var player_san_shield: TextureProgressBar = $"../../UI/BackgroundImage/Main_Container/Main_Elements/Combat_Container/NinePatchRect/player_stats_container/VBoxContainer2/player_san_shield"
@onready var enemy_shield: TextureProgressBar = $"../../UI/BackgroundImage/Main_Container/Main_Elements/Combat_Container/MarginContainer/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer2/enemy_shield"
@onready var enemy_san_shield: TextureProgressBar = $"../../UI/BackgroundImage/Main_Container/Main_Elements/Combat_Container/MarginContainer/HBoxContainer/VBoxContainer/NinePatchRect/VBoxContainer2/enemy_san_shield"


func _ready() -> void:
	if not Resources.is_node_ready():
		await Resources.ready
	await get_tree().process_frame
	if not Resources.Player.Stats_Changed.is_connected(update_bars_player):
		Resources.Player.Stats_Changed.connect(update_bars_player)
	if not Resources.Enemy.Stats_Changed.is_connected(update_bars_enemy):
		Resources.Enemy.Stats_Changed.connect(update_bars_enemy)	
	
	reset_bars()
	

func reset_bars() -> void:
	player_hp.max_value = Resources.Player.Max_HP
	player_san.max_value = Resources.Player.Max_SAN
	player_hp.value = Resources.Player.current_health
	player_san.value = Resources.Player.current_sanity
	enemy_san.value = Resources.Enemy.Max_HP
	enemy_san.max_value = Resources.Enemy.Max_SAN
	enemy_hp.value = Resources.Enemy.current_health
	enemy_san.value = Resources.Enemy.current_sanity
	player_shield.value = Resources.Player.current_block
	player_shield.value = Resources.Player.current_block
	player_san_shield.value = Resources.Player.current_san_block
	player_san_shield.value = Resources.Player.current_san_block
	enemy_shield.value = Resources.Enemy.current_block
	enemy_shield.value = Resources.Enemy.current_block
	enemy_san_shield.value = Resources.Enemy.current_san_block
	enemy_san_shield.value = Resources.Enemy.current_san_block
	reset_labels()


func reset_labels() -> void:
	enemy_hp.get_child(0).text = str(int(enemy_hp.value))
	enemy_san.get_child(0).text = str(int(enemy_san.value))
	player_hp.get_child(0).text = str(int(player_hp.value))
	player_san.get_child(0).text = str(int(player_san.value))

func update_bars_player() -> void:
	player_hp.change_value(Resources.Player.current_health)
	player_san.change_value(Resources.Player.current_sanity)
	player_shield.change_value(Resources.Player.current_block)
	player_san_shield.change_value(Resources.Player.current_san_block)

func update_bars_enemy() -> void:
	enemy_san.change_value(Resources.Enemy.current_sanity)
	enemy_hp.change_value(Resources.Enemy.current_health)
	enemy_shield.change_value(Resources.Enemy.current_block)
	enemy_san_shield.change_value(Resources.Enemy.current_san_block)
	
