class_name Attack_Action extends Enemy_Action
@onready var battle: Battle = $"."

var damage_type : String
var damage_base : int

func inflict_damage(target: TextureProgressBar, amount: int, damage_type: String, damage_bonus: int = 0) -> void:
	target.value = target.value + amount
