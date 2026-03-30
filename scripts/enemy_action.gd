class_name Enemy_Action extends Resource

@export var action_name: String
@export var action_type: String

@export var action_soundeffect: AudioStream
@export var action_log_message: String
@export var action_vfx: Callable


func inflict_damage(target: Combat_Entity, amount : int, damage_type : Damage_Type) -> void:
	target.take_damage(amount, damage_type) # <- NOT UI


func gain_shield(source, amount: int) -> void:
	source.add_shield(amount)


func execute(source, target) -> void:
	pass
