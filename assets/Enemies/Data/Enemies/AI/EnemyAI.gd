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

func can_use(action: EnemyAction) -> bool:
	if action.ActionEffect == EnemyAction.ActionEffects.Attack \
			and enemy and enemy.Enemy and enemy.Enemy.Entity.is_concussed():
		return false
	return true
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
		if not can_use(action):
			continue
		if action.is_usable():
			return action
	return null

func get_chance_action() -> EnemyAction:
	var pool: Array[EnemyAction] = []
	var total := 0.0
	for child in get_children():
		var action := child as EnemyAction
		if not action or action.ActionType != EnemyAction.ActionTypes.ChanceBased:
			continue
		if action.ActionChance <= 0.0 or not can_use(action):
			continue
		pool.append(action)
		total += action.ActionChance
	if pool.is_empty():
		return null
	var roll := randf_range(0.0, total)
	for action in pool:
		roll -= action.ActionChance
		if roll <= 0.0:
			return action
	return pool.back()


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
	
