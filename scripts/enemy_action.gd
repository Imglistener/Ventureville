class_name Enemy_Action extends Resource

@export var action_name: String
@export var action_type: String

@export var action_soundeffect: AudioStream
@export var action_log_message: String
@export var action_vfx: Callable


func inflict_damage(target: Player_Battle_Handler, amount : int, damage_type : Damage_Type) -> void:
	target.take_damage(amount) 

func damage_enemy(target: Combat_Entity, amount : int) -> void:
	target.take_damage(amount) 

func gain_shield(source, amount: int) -> void:
	source.add_shield(amount)


func execute(user : Node, source: Enemy_Data, target: Player_Battle_Handler) -> void:
	pass
