class_name Loadout extends Resource

@export var Class_Name : String

@export var HP			: int
@export var SAN			: int
@export var STRENGTH 	: int 
@export var BLOOD 		: int
@export var ENTROPY		: int
@export var INFLUENCE	: int

var Array_of_stats : Array = []

func apply_loadout(PLAYER : Player_Battle_Entity) -> void:
	Array_of_stats.append(HP)
	Array_of_stats.append(SAN)
	Array_of_stats.append(STRENGTH)
	Array_of_stats.append(BLOOD)
	Array_of_stats.append(ENTROPY)
	Array_of_stats.append(INFLUENCE)
	for i in Array_of_stats:
		match i:
			HP:
				PLAYER.Player_HP.stat_value 		= HP
			SAN:
				PLAYER.Player_SAN.stat_value 		= SAN
			STRENGTH:
				PLAYER.Player_Strength.stat_value 	= STRENGTH
			BLOOD:
				PLAYER.Player_Blood.stat_value		= BLOOD
			ENTROPY:
				PLAYER.Player_Entropy.stat_value	= ENTROPY
			INFLUENCE:
				PLAYER.Player_Influence.stat_value	= INFLUENCE
			
	
		
