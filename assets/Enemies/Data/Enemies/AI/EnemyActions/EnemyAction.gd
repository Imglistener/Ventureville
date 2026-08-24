class_name EnemyAction
extends Node

enum ActionTypes {Conditional, ChanceBased}
enum ActionEffects {Attack, Defend, Buff, Debuff, Transition}

@export var ActionType: ActionTypes
@export var ActionEffect: ActionEffects
@export var SoundEffect : AudioStream
@export_range(0.0, 10.0) var ActionChance: float = 0.0
@export_multiline var Description: String

var log: Log

@onready var TotalChance : float = 0.0

var Enemy: EnemyView
var target: Stat_Manager

func is_usable() -> bool:
	return false

func use_action() -> void:
	if self.log:
		self.log.text += "[br]"
		self.log.text += (Description)
		
