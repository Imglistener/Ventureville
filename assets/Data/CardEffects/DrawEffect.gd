class_name DrawEffect extends CardEffect

var amount : int

func activate(targets : Array[Node]) -> void:
	if targets[0]:
		var tree = targets[0].get_tree()
		var hand : CardHand = tree.get_first_node_in_group('hand')
		if hand:
				hand.draw_card(amount)
				
