class_name Deck extends Resource

@export var Obtained_Cards: Dictionary = {}
@export var Cards_in_Deck : Array = [Player_Action_instance]
var Battle_Deck : Array = []

func intialize_deck_contents() -> void:
	for Obtained_Card in Obtained_Cards.keys():
		if Obtained_Card in Cards_in_Deck:
			for copy in range(Obtained_Cards[Obtained_Card]):
				Battle_Deck.append(Obtained_Card)
