class_name EnemyAI extends Node

@export var enemy: EnemyView : set = _set_enemy
@export var target: Stat_Manager: set = _set_target

@onready var TotalChance:= 0


func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	setup_action_chances()
	for action in get_children():
		action.target = target
		action.log = get_tree().get_first_node_in_group('Log')

func get_action() -> EnemyAction:
	var action : EnemyAction = get_conditional_action()
	if action:
	
		return action

	return get_chance_action()

func get_conditional_action() -> EnemyAction:
	var action : EnemyAction
	
	for child in get_children():
		action = child as EnemyAction
		if not action or action.ActionType != EnemyAction.ActionTypes.Conditional:
			continue
		if action.is_usable():
			return action
	return null

func get_chance_action() -> EnemyAction:
	
	var action: EnemyAction
	var roll := randf_range(0.0, TotalChance)
	
	for child in get_children():
		action = child as EnemyAction
		if not action or action.ActionType != EnemyAction.ActionTypes.ChanceBased:
			continue
		if action.TotalChance > roll:
			return action
		
	return null


func setup_action_chances() -> void:
	TotalChance = 0
	var action : EnemyAction
	for child in get_children():
		action = child as EnemyAction
		if not action or action.ActionType != EnemyAction.ActionTypes.ChanceBased:
			continue
		TotalChance += action.ActionChance
		action.TotalChance = TotalChance

func _set_enemy(value: EnemyView) -> void:
	enemy = value
	for action in get_children():
		action.Enemy = enemy


func _set_target(value: Stat_Manager) -> void:
	target = value
	
func disable_attacks() -> void:
	for move in get_children():
		if not move or move.ActionType != EnemyAction.ActionTypes.ChanceBased or move.ActionEffect != EnemyAction.ActionEffects.Attack:
			continue
		else:
			move.ActionChance = 0
	setup_action_chances()

func enable_attacks() -> void:
	for move in get_children():
		if not move or move.ActionType != EnemyAction.ActionTypes.ChanceBased or move.ActionEffect != EnemyAction.ActionEffects.Attack:
			continue
		if move is EnemyAction:
			move.ActionChance = move.Enemy_Data.ActionChance
	setup_action_chances()
