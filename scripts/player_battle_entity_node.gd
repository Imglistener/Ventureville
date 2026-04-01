class_name Player_Battle_Handler extends Node

@export var Player 	: Player_Battle_Entity
@export var CLASS 	: Loadout
@onready var damage_numbers: Node2D = $"../damage_numbers"
@onready var battle_history: battle_log = %Log

var Max_HP : int
var Current_HP : int
var Max_San : int
var Current_San : int

signal player_took_damage(amount)

func get_player_data()-> void:
	Player.initialize_player_data(Player)
	Player.Player_HP.get_current_value(Player.Player_HP)
	Player.Player_SAN.get_current_value(Player.Player_SAN)
	Max_HP 		= Player.Player_HP.get_bars_value(Player.Player_HP)
	Current_HP	= Player.Player_HP.Current_Value
	Max_San		= Player.Player_SAN.get_bars_value(Player.Player_SAN)
	Current_San	= Player.Player_SAN.Current_Value
	
func take_damage(amount:int) -> void:
	Current_HP -= amount
	DamageNumbers.display_number(amount, damage_numbers.global_position, false)
	Player.Player_HP.Current_Value = Current_HP
	emit_signal("player_took_damage", amount)

func update_battle_history_on_action(action : Player_Action_instance) -> void:
	battle_history.text += str("\n"+action.action_log_message)

func _ready() -> void:
	get_player_data()
	
