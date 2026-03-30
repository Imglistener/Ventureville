class_name Player_Action_instance extends Player_Action

@export var associated_stat : stat_instance
@export var base_damage		: int

var damage_type 	: Damage_Type 
var status_effect 	: Status_Effect
var scaling_value	: int

func initialize_move(container: Button) -> void:
	var container_texture : TextureRect = container.get_child(1)
	damage_type = associated_stat.Associated_Damage_Type
	status_effect = associated_stat.Associated_Damage_Type.associated_status
	container_texture.texture = Action_Card_Art
	scaling_value = associated_stat.get_raw_scaling_value(associated_stat)
func apply_effect() -> void:
	pass


func basic_attack(target: Combat_Entity) -> void:
		var amount : int = base_damage + scaling_value
		print(scaling_value)
		target.takedamage(amount , damage_type)
