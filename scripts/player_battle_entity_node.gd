class_name Player_Battle_Handler extends Node

@export var Player 	: Player_Battle_Entity
@export var CLASS 	: Loadout

var Max_HP : int
var Current_HP : int
var Max_San : int
var Current_San : int

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
	Player.Player_HP.Current_Value = Current_HP
	

func _ready() -> void:
	get_player_data()
	
