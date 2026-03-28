class_name Burning extends Status_Effect

@export var associated_damage_type : String


func on_apply(source: Battle, target, duration) -> void:
	releaseDOT(target, duration) 
