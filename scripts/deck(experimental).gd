# DeckResource.gd
extends Resource
class_name DeckResource

@export var inventory: Array[Player_Action_instance] = []  # All cards player owns (ActionResources)
@export var deck: Array[Player_Action_instance] = []       # Current draw pile
@export var discard: Array[Player_Action_instance] = []    # Discard pile

# Shuffle the deck
func shuffle_deck():
	deck.shuffle()

# Initialize the deck from inventory
func build_deck():
	deck.clear()
	discard.clear()
	# Here you can decide how many copies of each card to put in deck
	for card in inventory:
		deck.append(card.duplicate())  # duplicate to avoid shared instance issues
	shuffle_deck()

# Draw cards from deck into hand
func draw(amount: int) -> Array[Resource]:
	var drawn_cards := []
	for i in range(amount):
		if len(deck) == 0:
			reshuffle_discard_into_deck()
		if len(deck) == 0:
			break  # no cards left at all
		var card = deck.pop_front()
		drawn_cards.append(card)
	return drawn_cards

# Play a card (moves it to discard pile)
func play_card(card: Resource) -> void:
	discard.append(card)

# Reshuffle discard back into deck
func reshuffle_discard_into_deck():
	if len(deck) == 0:
		return
	deck = discard.duplicate()
	discard.clear()
	deck.shuffle()

# Return all remaining cards in hand back to deck (end turn)
func return_hand_to_deck(hand_cards: Array[Resource]) -> void:
	for card in hand_cards:
		deck.append(card)
