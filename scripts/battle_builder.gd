class_name BattleBuilder
extends Node
@onready var dialogue_node: NinePatchRect = $"../../Control_Layer/Control_Base/Base_Margin/StandbyContainer/dialogue-node"

@export var enemy_view_container: EnemyViewContainer2D 
@export var enemy_manager: EnemyManager
@export var bgm : AudioStreamPlayer
@export var battle_info : BattleInfo
@export var SM: PackedScene

var Dialogue_manager

func _ready() -> void:
	if not enemy_manager.is_node_ready():
		await enemy_manager.ready
	if not Dialogue_manager:
		Dialogue_manager = dialogue_node.dialogue_manager
		
	build()

func build() -> void:
	clear_current_battle()
	var enemies := battle_info.enemies_involved
	var views := enemy_view_container.build_enemy_views(enemies.size())

	for i in enemies.size():
		var new_manager := SM.instantiate() as Stat_Manager
		new_manager.Entity = enemies[i]
		new_manager.enemy_ai = enemies[i].Enemy_AI
		new_manager.enemy = views[i]
		new_manager.enemy_manager = enemy_manager
		views[i].process_mode = Node.PROCESS_MODE_INHERIT
		get_parent().call_deferred('add_child', new_manager)

	bgm.stream = battle_info.battle_music
	bgm.play()
	await get_tree().process_frame
	



func clear_current_battle() -> void:
	for view in enemy_manager.get_enemy_views():
		enemy_manager.unregister(view)
		view.queue_free()
	for child in get_parent().get_children():
		if child is Stat_Manager and child.Entity is EnemyBattlerStats:
			child.queue_free()
