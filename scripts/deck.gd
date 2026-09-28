class_name Deck extends Resource
@export var Obtained_Cards: Dictionary[Card, int]
@export var Card_Amount_In_Deck: Dictionary[Card, int]

var Battle_Deck : Array[Card] = []
var Discard_Pile: Array[Card] = []
var TheHand		: Array[Card] = []
signal DeckSize_Changed(cards_left)
signal DiscardSize_Changed(discards_left)
signal card_added_to_deck
signal card_removed_from_deck

func intialize_deck_contents() -> void:
	for Obtained_Card in Obtained_Cards.keys():
		if Obtained_Card in Card_Amount_In_Deck.keys():
			for copy in range(Card_Amount_In_Deck[Obtained_Card]):
				Battle_Deck.append(Obtained_Card)

func empty() -> bool:
	return Battle_Deck.is_empty()

func draw_card() -> Card:
	if Battle_Deck.is_empty():
		Battle_Deck += Discard_Pile
		Discard_Pile.clear()
		shuffle_deck() 
		DeckSize_Changed.emit(Battle_Deck.size())
		DiscardSize_Changed.emit(Discard_Pile.size())
	var card_drawn = Battle_Deck.pop_front()
	TheHand.append(card_drawn)
	DeckSize_Changed.emit(Battle_Deck.size())
	return card_drawn

func add_card(card: Card) -> void:
	Battle_Deck.append(card)
	DeckSize_Changed.emit(Battle_Deck.size())

func shuffle_deck() -> void:
	Battle_Deck.shuffle()

func card_played(played_card: Card) -> void:
	if not played_card in TheHand:
		return
	Discard_Pile.append(played_card)
	TheHand.erase(played_card)
	DiscardSize_Changed.emit(Discard_Pile.size())

func clear_deck() -> void:
	Battle_Deck.clear()
	DeckSize_Changed.emit(Battle_Deck.size())

func discard_hand() -> void:
	Discard_Pile += TheHand
	TheHand.clear()
	DeckSize_Changed.emit(Battle_Deck.size())

func _to_string() -> String:
	var _card_string: PackedStringArray = []
	for i in range(Battle_Deck.size()):
		_card_string.append("%s: %s" %[i+1, Battle_Deck[i].id])
	return "\n".join(_card_string)

func add_card_to_deck(card: Card) -> void:
	if Obtained_Cards[card]:
		if Obtained_Cards[card] > 0:
			if Card_Amount_In_Deck[card]:
				Card_Amount_In_Deck[card] += 1
			else:
				Card_Amount_In_Deck[card] = 1
			Obtained_Cards[card] -= 1
	card_added_to_deck.emit()

func remove_card_from_deck(card: Card) -> void:
	if Card_Amount_In_Deck[card]:
		if Card_Amount_In_Deck[card] > 0:
			if Obtained_Cards[card]:
				Obtained_Cards[card] += 1
			else:
				Obtained_Cards[card] = 1
			Card_Amount_In_Deck[card] -= 1
	card_removed_from_deck.emit()
