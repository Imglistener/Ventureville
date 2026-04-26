class_name Deck extends Resource
@export var Obtained_Cards: Dictionary = {}
@export var Cards_in_Deck : Array[Card] = []
var Battle_Deck : Array[Card] = []
var Discard_Pile: Array[Card] = []
var TheHand		: Array[Card] = []
signal DeckSize_Changed(cards_left)
signal DiscardSize_Changed(discards_left)

func intialize_deck_contents() -> void:
	for Obtained_Card in Obtained_Cards.keys():
		if Obtained_Card in Cards_in_Deck:
			for copy in range(Obtained_Cards[Obtained_Card]):
				Battle_Deck.append(Obtained_Card)

func empty() -> bool:
	return Battle_Deck.is_empty()

func draw_card() -> Card:
	if Battle_Deck.is_empty():
		Battle_Deck += Discard_Pile
		Discard_Pile.clear()
		shuffle_deck() # FIX 3: shuffle after recycling discard pile
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
