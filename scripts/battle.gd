class_name Battle extends Control

@onready var _battleMenu :  = $MarginMain/VBoxContainer/Interface/NinePatchRect/ActionsMenu/Buttonhandlesystem
@onready var _ActionsMenu = $MarginMain/VBoxContainer/Interface/NinePatchRect/ActionsMenu/Buttonhandlesystem
@onready var enemy_container: MarginContainer = $MarginMain/VBoxContainer/Arena/MarginContainer/HBoxContainer/Enemy_container
@onready var player_hp: TextureProgressBar = $MarginMain/VBoxContainer/Arena/MarginContainer/HBoxContainer/NinePatchRect2/Player_container/player_portrait/player_stats_container/VBoxContainer/player_hp
@onready var enemy: Enemy = %Enemy
@onready var sfx: AudioStreamPlayer2D = $SFX
@onready var bgm: AudioStreamPlayer2D = $BGM
@onready var battle_log : Log = %Log
@onready var is_active: Label = %Is_Active



const damage_types: Array = ["Fire", "Blood", "Psychic", "Dark", "Physical", "Ice"]



signal just_dealt_damage(damage_type, target)
signal turn_changed(turn_counter)
signal Enemy_Battlephase_Done()

var turn_counter			: int = 0
var is_player_turn			: bool = true
var is_battlephase			: bool = false
var is_standbyphase_player	: bool = false
var is_standbyphase_enemy	: bool = false
var is_battlephase_enemy	: bool = false
var action_points 			: int = 3
var magic_points 			: int = 1


var active_effects : Array = []


func execute_action(action : Enemy_Action, target: TextureProgressBar) -> void:
	if action is Attack_Action:
		inflict_damage(target, int(action.damage_base) + int(enemy.Enemy_basestats["eAttackBonus"]), enemy.Enemy_basestats["eDamagetype"] )
	sfx.stream = action.Action_soundeffect
	sfx.play()
	battle_log.text += "\n" + action.Action_log_message
	
func inflict_damage(target: TextureProgressBar, amount: int, damage_type: String) -> void:
	if damage_type in damage_types:
		target.value = target.value + amount
		emit_signal("just_dealt_damage", damage_type, target)
	else:
		print("Invalid Damage Type.")
		

func hide_UI(target: Control) -> void:
	target.hide()
func show_UI(target: Control) -> void:
	target.show()
	
func _on_enemy_standbyphase_done() -> void:
	is_standbyphase_enemy = false
	while action_points > 0:
		enemy.choose_action(enemy.enemy_actions)
		action_points -= 1
		await sfx.finished
	if action_points == 0:
		emit_signal("Enemy_Battlephase_Done")
		turn_counter_tick()
		emit_signal("turn_changed")
		is_battlephase_enemy = false
		is_player_turn = true	

func _ready() -> void:
	#StartupActions
	enemy.StandbyPhase_Done.connect(_on_enemy_standbyphase_done)
	Enemy_Battlephase_Done.connect(_on_Enemy_battlephase_done)
	#ManageBattleLogic
	#ManageMenusAndPhases
	_ActionsMenu.button_focus_manage(0)
	is_standbyphase_player 	= true
	is_player_turn 			= true

	
func _activate_turn_counter() -> void:
	if turn_counter % 2 == 0:
		is_player_turn = true
	elif turn_counter % 2 != 0:
		is_player_turn = false
		
func turn_counter_tick() -> void:
	turn_counter += 1
	action_points = 3
	
func mana_tick() -> int:
	magic_points += 1
	return magic_points

func _process(_delta: float) -> void:
	if not is_player_turn:
		hide_UI($MarginMain/VBoxContainer/EnemyInfo/NinePatchRect2/MarginContainer)
		hide_UI(%ActionsMenu)
		hide_UI(%Battleactions)
		show_UI($MarginMain/VBoxContainer/EnemyInfo/NinePatchRect2/Message)
		is_active.text = "Enemy's Turn"
	if is_player_turn:
		show_UI($MarginMain/VBoxContainer/EnemyInfo/NinePatchRect2/MarginContainer)
		hide_UI($MarginMain/VBoxContainer/EnemyInfo/NinePatchRect2/Message)
		is_active.text = "Your Turn"
		if is_battlephase: 
			hide_UI(%ActionsMenu)
	if is_player_turn:
		if is_battlephase:
			if Input.is_action_just_pressed("esc"):
					is_battlephase = false
					is_standbyphase_player = true	

func _on_actions_menu_visibility_changed() -> void:
	if not is_node_ready():
		return
	_ActionsMenu.button_focus_manage(0)


func _on_battle_pressed() -> void:
	is_standbyphase_player = false
	is_battlephase = true


func _on_battle_tree_entered() -> void:
	is_battlephase = false
	


func _on_end_turn_pressed() -> void:
	is_battlephase = false
	is_player_turn = false
	turn_counter_tick()
	emit_signal("turn_changed")
	is_standbyphase_enemy = true


func _on_Enemy_battlephase_done()-> void:
	mana_tick()
	show_UI(%ActionsMenu)
