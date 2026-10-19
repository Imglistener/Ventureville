extends BuffCard
## Sacrifice, then draw 1. Until Ascendant State has been played this battle, the draw is
## replaced by Ascendant State itself: it is pulled from the draw pile or discard pile
## (or created if it isn't in the deck) and drawn into your hand.
## Card stats (0 AP / 1 MP, Common, blood_tax = 5, target = SELF) are set in the .tres.

## Add this tag to Ascendant State.tres: tags = Array[StringName]([&"AscendantState"])
const TAG_ASCENDANT_STATE := &"AscendantState"

@export var ascendant_state: Card   # assign Ascendant State.tres
@export var draw_amount: int = 1


func _played_ascendant_state(player: Stat_Manager) -> bool:
	var tracker := _get_turn_tracker(player)
	return tracker != null and tracker.played_tag_this_battle(TAG_ASCENDANT_STATE)


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)

	if ascendant_state and not _played_ascendant_state(player):
		_put_on_top_of_deck(player.Player.starting_deck)
	# Either way we draw: the top card is now Ascendant State, or it's a normal draw.
	_draw_cards(targets, draw_amount)


## Moves Ascendant State to the top of the draw pile so the draw picks it up.
## If it's already in your hand, nothing is moved and you just draw normally.
func _put_on_top_of_deck(deck: Deck) -> void:
	if deck.TheHand.has(ascendant_state):
		return
	if deck.Battle_Deck.has(ascendant_state):
		deck.Battle_Deck.erase(ascendant_state)
	elif deck.Discard_Pile.has(ascendant_state):
		deck.Discard_Pile.erase(ascendant_state)
		deck.DiscardSize_Changed.emit(deck.Discard_Pile.size())
	deck.Battle_Deck.push_front(ascendant_state)
	deck.DeckSize_Changed.emit(deck.Battle_Deck.size())


func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	if live_targets.is_empty() or not live_targets[0] or not ascendant_state:
		return Description
	var player := live_targets[0].get_tree().get_first_node_in_group("player") as Stat_Manager
	if player and not _played_ascendant_state(player):
		return Description + "\n(Add Ascendant State to your hand)"
	return Description + "\n(Draw %d)" % draw_amount
