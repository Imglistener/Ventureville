class_name Battle_Condition extends Resource

enum CONDITION_TYPES{Passive, Active}

@export_group('Condition_Info')
@export var condition_name : String
@export var condition_type : CONDITION_TYPES
@export var condition_icon : Texture2D
@export_multiline var condition_description: String


func is_condition_passive() -> bool:
	return condition_type == CONDITION_TYPES.Passive

func is_condition_active() -> bool:
	return condition_type == CONDITION_TYPES.Active

func on_apply(targets: Array[Node]) -> void:
	pass

func on_tick(targets: Array[Node]) -> void:
	pass

func on_expired(targets: Array[Node]) -> void:
	pass

func activate(targets: Array[Node]) -> void:
	pass
