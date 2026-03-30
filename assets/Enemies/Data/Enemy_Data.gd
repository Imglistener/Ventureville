class_name Enemy_Data extends Enemy_Revised

@export var name:		String	
@export var HP: 		int
@export var SAN: 		int
@export var ATK_bonus: 	int
@export var RES:		Damage_Type
@export var VUL:		Damage_Type
@export var AP:			int = 3

var enemy_stats : Array

func initalize_enemy_stats() -> Array:
	if name == null:
			pass
	else: enemy_stats.append(name)
	if HP == null:
		pass
	else: enemy_stats.append(HP)
	if SAN == null:
		pass
	else: enemy_stats.append(SAN)
	if ATK_bonus == null:
		pass
	else: enemy_stats.append(ATK_bonus)
	if RES == null:
		pass
	else: enemy_stats.append(RES)
	if VUL == null:
		pass
	else: enemy_stats.append(VUL)
	if AP == null:
		pass
	else: enemy_stats.append(AP)
	

	
	return	enemy_stats
