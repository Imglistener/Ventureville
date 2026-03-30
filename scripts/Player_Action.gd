class_name Player_Action extends Enemy_Action

@export var Action_Cost_MP : int
@export var Action_Cost_HP : int = 0
@export var Action_Cost_AP : int
@export var Action_Card_Art: Texture2D

@export var Action_Card_VFX : Callable

func use_action(action : )-> void:
	action.apply_effect()
