class_name UI_manager extends Node

@onready var battle_manager: Battle_Manager 	= %Battle_Manager
@onready var ENEMY : Combat_Entity				= %Combat_Entity
@onready var TURN: Label = %Is_Active
@onready var ENEMY_NAME: Label = %Enemy_name
@onready var enemy_action: Label = %Enemy_Action
@onready var e_heathbar: TextureProgressBar = %E_Heathbar
@onready var e_san_bar: TextureProgressBar = %E_SanBar
@onready var HP_Number: Label = $"../MarginMain/VBoxContainer/EnemyInfo/NinePatchRect2/MarginContainer/HBoxContainer/E_Heathbar/E_HP"
@onready var SAN_Number: Label = $"../MarginMain/VBoxContainer/EnemyInfo/NinePatchRect2/MarginContainer/HBoxContainer/E_SanBar/E_SAN"
@onready var BATTLE_LOG: battle_log = %Log
@onready var PLAYER: Player_Battle_Handler = %Player_Battle_Entity
@onready var player_hp: TextureProgressBar = $"../MarginMain/VBoxContainer/Arena/MarginContainer/HBoxContainer/NinePatchRect2/Player_container/player_portrait/player_stats_container/VBoxContainer/player_hp"
@onready var player_san: TextureProgressBar = $"../MarginMain/VBoxContainer/Arena/MarginContainer/HBoxContainer/NinePatchRect2/Player_container/player_portrait/player_stats_container/VBoxContainer/player_san"
@onready var player_hp_counter: Label = $"../MarginMain/VBoxContainer/Arena/MarginContainer/HBoxContainer/NinePatchRect2/Player_container/player_portrait/player_stats_container/VBoxContainer/player_hp/player_hp_counter"
@onready var player_san_counter: Label = $"../MarginMain/VBoxContainer/Arena/MarginContainer/HBoxContainer/NinePatchRect2/Player_container/player_portrait/player_stats_container/VBoxContainer/player_san/player_san_counter"
@onready var playernamedisplay: Label = $"../MarginMain/VBoxContainer/Arena/MarginContainer/HBoxContainer/NinePatchRect2/Player_container/player_portrait/player_stats_container/playernamedisplay"
@onready var manacounter: TextureProgressBar = $"../MarginMain/VBoxContainer/Interface/NinePatchRect/Battleactions/MarginContainer/HBoxContainer/manacounter"
@onready var mana: Label = $"../MarginMain/VBoxContainer/Interface/NinePatchRect/Battleactions/MarginContainer/HBoxContainer/manacounter/Mana"
@onready var actions_menu: HBoxContainer = %ActionsMenu
@onready var battleactions: NinePatchRect = %Battleactions
@onready var zahando: MarginContainer = $"../MarginMain/VBoxContainer/Interface/NinePatchRect/Battleactions/Zahando"
@onready var ap: Label = $"../MarginMain/VBoxContainer/EnemyInfo/NinePatchRect2/MarginContainer/HBoxContainer/Action_Points/AP"
@onready var action_points: TextureProgressBar = %Action_Points


#Transition Effect Function:
func transition_to(show_node: Control, hide_node: Control = null) -> void:
	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	# 🔻 Hide current
	if hide_node:
		t.tween_property(hide_node, "modulate:a", 0.0, 0.25)
		t.parallel().tween_property(hide_node, "scale", Vector2(0.95, 0.95), 0.25)
	
		await t.finished
		hide_node.visible = false
	
	# 🔺 Prepare new node
	show_node.visible = true
	show_node.modulate.a = 0.0
	show_node.scale = Vector2(1.05, 1.05)
	
	# 🔺 Show animation
	var t2 = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	t2.tween_property(show_node, "modulate:a", 1.0, 0.3)
	t2.parallel().tween_property(show_node, "scale", Vector2.ONE, 0.3)


	
	
func _process(_delta: float) -> void:
	pass
	
func Actualize_AP() -> void:
	action_points.max_value = battle_manager.action_points
	action_points.value		= battle_manager.action_points
	ap.text					= str(battle_manager.action_points)

	

func update_turn_counter() -> void:
	if battle_manager.turn_counter % 2 == 0:
		TURN.text = "Enemy's Turn"
	else: 
		TURN.text = "Your Turn"
func update_enemy_info() -> void:
	ENEMY_NAME.text = str(ENEMY.enemy_stats[0])
	e_heathbar.max_value = ENEMY.enemy_stats[1]
	e_heathbar.value = e_heathbar.max_value
	e_san_bar.max_value = ENEMY.enemy_stats[2]
	e_san_bar.value = ENEMY.enemy_stats[2]
	HP_Number.text = str(int(e_heathbar.max_value))
	SAN_Number.text = str(int(e_san_bar.max_value))

func update_player_info_display()-> void:
	player_hp.max_value 	= PLAYER.Max_HP
	player_hp.value			= PLAYER.Current_HP
	player_hp_counter.text 	= str(PLAYER.Current_HP)
	player_san.max_value 	= PLAYER.Max_San
	player_san.value		= PLAYER.Current_San
	player_san_counter.text = str(PLAYER.Current_San)
	playernamedisplay.text 	= str(PLAYER.Player.Assigned_Class.Class_Name)
	
	
	
func log_update(text: String = str(battle_manager.turn_counter)) -> void:
	if text == str(battle_manager.turn_counter):
		BATTLE_LOG.text = BATTLE_LOG.text + "\n" + "Turn " + text +":"
	else:
		BATTLE_LOG.text = BATTLE_LOG.text + "\n" + text

func mana_counter_functionality() -> void:
	manacounter.max_value 	= battle_manager.mana_counter
	manacounter.value		= battle_manager.mana_counter
	mana.text				= str(battle_manager.mana_counter)
func _on_combat_entity_attack_just_landed(damage_type: Variant, amount) -> void:
	e_heathbar.value = ENEMY.enemy_stats[1]
	HP_Number.text = str(int(ENEMY.enemy_stats[1]))
func _on_battle_manager_player_standby_phase_start() -> void:
	await get_tree().process_frame
	if not actions_menu.is_node_ready():
		await actions_menu.ready
	if not battleactions.is_node_ready():
		await  battleactions.ready
	transition_to(actions_menu, battleactions)
	update_turn_counter()
	update_enemy_info()
	update_player_info_display()
	log_update()
	Actualize_AP()
	mana_counter_functionality()


func _on_battle_manager_player_standby_phase_end() -> void:
	transition_to(battleactions, actions_menu)
	zahando.draw_cards(5)
