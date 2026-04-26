class_name EnemyAction
extends Node

enum ActionTypes {Conditional, ChanceBased}

@export var ActionType: ActionTypes
@export var SoundEffect : AudioStream
@export_range(0.0, 10.0) var ActionChance: float = 0.0
@export_multiline var Description: String


@onready var TotalChance : float = 0.0

var Enemy: EnemyView
var target: Stat_Manager

func is_usable() -> bool:
	return false

func use_action() -> void:
	pass
