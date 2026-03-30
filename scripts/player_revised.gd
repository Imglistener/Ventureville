class_name Player_Battle_Entity extends Resource

@export var Player_Name : String
@export var Player_HP	: stat_instance
@export var Player_SAN	: stat_instance
@export var Player_Entropy: stat_instance
@export var Player_Blood: stat_instance
@export var Player_Strength: stat_instance
@export var Player_Influence: stat_instance
@export var Assigned_Class : Loadout


func save_stats_to_resource() -> void:
	Player_HP.stat_value = Assigned_Class.HP
	Player_SAN.stat_value = Assigned_Class.SAN
	Player_Influence.stat_value = Assigned_Class.INFLUENCE
	Player_Entropy.stat_value =	Assigned_Class.ENTROPY
	Player_Strength.stat_value = Assigned_Class.STRENGTH
	Player_Blood.stat_value	= Assigned_Class.BLOOD

func initialize_player_data(Player : Player_Battle_Entity)-> void:
	Assigned_Class.apply_loadout(Player)
	save_stats_to_resource()
