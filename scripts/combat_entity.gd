class_name Combat_Entity extends Node
@onready var enemy_view: Enemy_View = $Enemy_view
@onready var player_battle_entity: Player_Battle_Handler = %Player_Battle_Entity
@onready var battle_manager: Battle_Manager = %Battle_Manager
@onready var sfx: AudioStreamPlayer2D = %SFX
@onready var log: battle_log = %Log

@export var enemy_behavior 	: Enemy_Revised
@export var enemy_data 		: Enemy_Data

var enemy_stats 	: Array
var enemy_actions 	: Array

signal enemy_stats_ready
signal enemy_done_attacking
signal attack_just_landed(damage_type, amount)
signal enemy_battle_ready
var attacked_this_turn : bool = false

func _ready()-> void:
	enemy_actions 	= enemy_behavior.initialize_enemy_moves()
	enemy_stats 	= enemy_data.initalize_enemy_stats()
	emit_signal("enemy_stats_ready")
	update_enemy_view(enemy_view, enemy_behavior)
	

func take_damage(amount: int) -> void:
	enemy_stats[1] -= amount
	emit_signal("attack_just_landed", amount)

func choose_action() -> void:
	while battle_manager.action_points > 0:
			for action in enemy_actions:
				if action is Attack_Action:
					if action.cost <= battle_manager.action_points:
						await execute_action(action)
						battle_manager.action_points -= action.cost
	emit_signal('enemy_done_attacking')

func execute_action(action: Enemy_Action) -> void:
	log.text += "\n" + action.action_log_message
	sfx.stream = action.action_soundeffect
	sfx.play()
	await sfx.finished
	action.execute(self, enemy_data, player_battle_entity)
	

func update_enemy_view(enemy_view: Enemy_View, enemy_textures : Enemy_Revised) -> void:
	enemy_view.texture_normal 	= enemy_textures.Texture_Normal
	enemy_view.texture_hover	= enemy_textures.Texture_Hover
	enemy_view.texture_focused	= enemy_textures.Texture_Hover
	enemy_view.texture_pressed	= enemy_textures.Texture_Press	
	enemy_view.texture_disabled =  enemy_textures.Texture_Normal


	


func _on_battle_manager_enemy_standby_phase_end() -> void:
	emit_signal('enemy_battle_ready')


func _on_battle_manager_enemy_battle_phase_start() -> void:
	choose_action()
