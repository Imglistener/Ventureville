extends BuffCard
## Generic 'attach a battle condition' card: Fear Itself, Stage Presence, Method Acting,
## Collective Dread, Reverberation. Assign the condition .tres in `condition`.

@export var condition: BattleCondition


func _execute(_player: Stat_Manager, targets: Array[Node]) -> void:
	_activate_condition(condition, targets)
