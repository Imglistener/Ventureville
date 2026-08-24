class_name GameStateManager extends Node
@onready var defeat: Label = $"../../Control_Layer/Pause Layer/Pause Blur/Defeat"
@onready var victory: Label = $"../../Control_Layer/Pause Layer/Pause Blur/Victory"
@onready var pause_blur: ColorRect = $"../../Control_Layer/Pause Layer/Pause Blur"
@onready var menus_manager: MenusManager = $"../MenusManager"
@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var enemy_manager: EnemyManager = $"../EnemyManager"


func _ready() -> void:
	if not player_stat_manager.is_node_ready():
		await player_stat_manager.ready

	if not player_stat_manager.EntityDied.is_connected(_on_entity_died):
		player_stat_manager.EntityDied.connect(_on_entity_died)

	enemy_manager.connect_and_catch_up(_on_enemy_registered)


func _on_enemy_registered(view: EnemyView, stat_manager: Stat_Manager) -> void:
	if not stat_manager.EntityDied.is_connected(_on_entity_died):
		stat_manager.EntityDied.connect(_on_entity_died)


func _on_entity_died(view: EnemyView, stat_manager: Stat_Manager) -> void:
	if view == null:
		_play_lose_sequence()
	elif enemy_manager.get_enemy_views().is_empty():
		_play_win_sequence()


func handle_blur(paused: bool) -> void:
	var t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(pause_blur.material, "shader_parameter/blur_amount", 0.0 if paused else 2.0, 0.4)
	await t.finished
	pause_blur.mouse_filter = Control.MOUSE_FILTER_STOP


func _play_win_sequence() -> void:
	victory.visible = true
	handle_blur(false)
	get_tree().paused = true


func _play_lose_sequence() -> void:
	defeat.visible = true
	handle_blur(false)
	get_tree().paused = true
