class_name Attack_Action extends Enemy_Action



@export var damage_base : int
@export var damage_type : Damage_Type


func attack(source_enemy : Enemy_Data, target: Combat_Entity) -> void:
	var amount = damage_base + source_enemy.ATK_bonus
	inflict_damage(target, amount, damage_type)

func execute(source: Enemy_Data, target: Combat_Entity)-> void:
	attack(source, target)
