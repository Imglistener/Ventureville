class_name Card extends Resource

enum Type{ATTACK, BUFF, DEBUFF, DEFEND}
enum Target{SELF, ONEENEMY, ALLENEMIES, ALL}

@export_group("Card Details")
@export var name: String
@export var type: Type
@export var target: Target
@export var mp_cost: int
@export var ap_cost: int
@export_multiline var Description: String

func is_SingleTarget() -> bool:
	return target == Target.ONEENEMY

func _get_targets(targets: Array[Node]) -> Array[Node]:
	if not targets:
		return []
	var tree := targets[0].get_tree()
	match target:
		Target.SELF:
			return tree.get_nodes_in_group("player")
		Target.ALLENEMIES:
			return tree.get_nodes_in_group("Enemies")
		Target.ALL:
			return tree.get_nodes_in_group("player") +  tree.get_nodes_in_group("Enemies")
		_:
			return []

func activate_card(targets: Array[Node], characterstats: CharacterInstance) -> void:
	Events.card_played.emit(self)
	characterstats.mana -= mp_cost
	characterstats.AP -= ap_cost
	if is_SingleTarget():
		apply_effect(targets)
	else:
		apply_effect(_get_targets(targets))

func apply_effect(_targets : Array[Node]) -> void:
	pass
