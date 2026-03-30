class_name Enemy_Revised extends Resource

@export var Enemy_Name		: String 
@export var Enemy_Attack_01 : Enemy_Action
@export var Enemy_Attack_02 : Enemy_Action
@export var Enemy_Attack_03 : Enemy_Action
@export var Enemy_Buff		: Enemy_Action
@export var Enemy_Debuff	: Enemy_Action
@export var Phase_2			: Enemy_Data

@export var Texture_Normal	: Texture2D
@export var Texture_Hover	: Texture2D
@export var Texture_Press	: Texture2D
@export var Texture_Focus	: Texture2D



var has_shield 				: bool = false
var is_alive				: bool = true
var has_status				: bool = false	

var Enemy_Moves: Array = []

func initialize_enemy_moves() -> Array:
	if Enemy_Attack_01 == null:
		pass
	else: Enemy_Moves.append(Enemy_Attack_01)
	if Enemy_Attack_02 == null:
		pass
	else: Enemy_Moves.append(Enemy_Attack_02)
	if Enemy_Attack_03 == null:
		pass
	else: Enemy_Moves.append(Enemy_Attack_03)
	if Enemy_Buff == null:
		pass
	else: Enemy_Moves.append(Enemy_Buff)
	if Enemy_Debuff == null:
		pass
	else: Enemy_Moves.append(Enemy_Attack_01)
	return	Enemy_Moves

func modulate_stats() -> void:
	pass
