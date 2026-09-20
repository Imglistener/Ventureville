class_name BattleCondition extends Resource

enum CONDITION_TYPES{Passive, Active}

@export_group('Condition_Info')
@export var condition_name : String
@export var condition_type : CONDITION_TYPES
@export var condition_icon : Texture2D
@export var condition_texture: Texture2D
@export_multiline var condition_description: String
@export var trigger_once: bool = false   # Active-only: remove self after firing once

func is_condition_passive() -> bool:
	return condition_type == CONDITION_TYPES.Passive

func is_condition_active() -> bool:
	return condition_type == CONDITION_TYPES.Active

# Active conditions: checked every tick, returns whether the payload should fire
func on_conditions_met(_targets: Array[Node]) -> bool:
	return false

# Passive conditions: runs every tick, unconditionally
func on_tick(_targets: Array[Node]) -> void:
	pass

# Active conditions: the actual payload, run once on_conditions_met returns true
func on_trigger(_targets: Array[Node]) -> void:
	pass

# Attaches the condition to an entity
func activate(_targets: Array[Node]) -> void:
	pass

# Removes the condition from whatever pool it's attached to
func on_expired(targets: Array[Node]) -> void:
	if targets.is_empty() or not targets[0]:
		return
	var player = targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	if not player:
		return
	var existing = find_same_effect(player.Player.BattleConditions)
	if existing:
		player.Player.BattleConditions.erase(existing)
		Events.BattleConditionExpired.emit(existing, player.Player)


func find_same_effect(effects: Array) -> BattleCondition:
	for effect in effects:
		if effect.get_script() == self.get_script():
			return effect
	return null
	
