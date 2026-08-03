class_name GainMPEffect extends CardEffect

var amount : int

func activate(targets : Array[Node]) -> void:
	if targets[0]:
		var tree = targets[0].get_tree()
		var player : CharacterInstance = tree.get_first_node_in_group('player').Player
		if player and amount:
			player.mana += amount
