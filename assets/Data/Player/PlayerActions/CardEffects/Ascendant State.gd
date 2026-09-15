extends Card

@export var blood_tax: int
@export var condition : Battle_Condition

func activate_card(targets: Array[Node], characterstats: CharacterInstance) -> void:
	targets[0].get_tree().get_first_node_in_group('player').Player.true_take_damage(blood_tax)
	condition.activate(targets)
	
