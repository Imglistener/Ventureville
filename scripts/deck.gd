class_name Deck extends Resource

## TOTAL copies owned per card.
@export var Obtained_Cards: Dictionary[Card, int]
## Copies currently placed in the deck (always <= owned).
@export var Card_Amount_In_Deck: Dictionary[Card, int]

var Battle_Deck : Array[Card] = []
var Discard_Pile: Array[Card] = []
var TheHand		: Array[Card] = []
signal DeckSize_Changed(cards_left)
signal DiscardSize_Changed(discards_left)
signal card_added_to_deck
signal card_removed_from_deck

# ---------- collection queries ----------
func get_owned(card: Card) -> int:
	return Obtained_Cards.get(card, 0)

func get_in_deck(card: Card) -> int:
	return Card_Amount_In_Deck.get(card, 0)

func get_available(card: Card) -> int:
	return maxi(get_owned(card) - get_in_deck(card), 0)

func can_add_to_deck(card: Card) -> bool:
	return card != null and get_available(card) > 0

func can_remove_from_deck(card: Card) -> bool:
	return card != null and get_in_deck(card) > 0

# ---------- deck editing ----------
func add_card_to_deck(card: Card) -> void:
	if not can_add_to_deck(card):
		return
	Card_Amount_In_Deck[card] = get_in_deck(card) + 1
	card_added_to_deck.emit()

func remove_card_from_deck(card: Card) -> void:
	if not can_remove_from_deck(card):
		return
	Card_Amount_In_Deck[card] = get_in_deck(card) - 1
	card_removed_from_deck.emit()
func clear_deck_to_collection() -> void:
	if Card_Amount_In_Deck.is_empty():
		return
	Card_Amount_In_Deck.clear()
	card_removed_from_deck.emit()
	
func reconcile_in_deck(counts: Dictionary) -> void:
	Card_Amount_In_Deck.clear()
	for card in counts.keys():
		if counts[card] > 0:
			Card_Amount_In_Deck[card] = counts[card]
func save_to_disk() -> Error:
	if resource_path.is_empty():
		push_warning("Deck.save_to_disk: no resource_path set.")
		return ERR_FILE_NOT_FOUND
	return ResourceSaver.save(self, resource_path)
## For rewards / shops: adds to the collection, NOT to the deck.
func add_card_to_collection(card: Card, amount: int = 1) -> void:
	if not card or amount <= 0:
		return
	Obtained_Cards[card] = get_owned(card) + amount

# ---------- battle ----------
func intialize_deck_contents() -> void:
	Battle_Deck.clear()
	Discard_Pile.clear()
	TheHand.clear()
	for card in Card_Amount_In_Deck.keys():
		var copies := mini(get_in_deck(card), get_owned(card))
		for i in range(copies):
			Battle_Deck.append(card)

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
		_card_string.append("%s: %s" % [i + 1, Battle_Deck[i].name])
	return "\n".join(_card_string)
