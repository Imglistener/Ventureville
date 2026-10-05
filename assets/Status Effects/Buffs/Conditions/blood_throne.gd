class_name BloodThroneCondition
extends BattleCondition

@export var mana_per_sacrifice: int = 1

var _owner: CharacterInstance


func activate(targets: Array[Node]) -> void:
	var player := targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	if not player or find_same_effect(player.Player.BattleConditions):
		return
	var instance := self.duplicate() as BloodThroneCondition
	instance._owner = player.Player
	player.Player.hp_sacrificed.connect(instance._on_hp_sacrificed)
	player.Player.BattleConditions.append(instance)
	Events.BattleConditionActivated.emit(instance, player.Player)
	Events.effect_display.emit(self, player.Player.damage_number_anchor, player.Player.damage_number_anchor.global_position)


func _on_hp_sacrificed(_amount: int) -> void:
	if _owner:
		_owner.mana += mana_per_sacrifice


func on_expired(targets: Array[Node]) -> void:
	if _owner and _owner.hp_sacrificed.is_connected(_on_hp_sacrificed):
		_owner.hp_sacrificed.disconnect(_on_hp_sacrificed)
	super(targets)
