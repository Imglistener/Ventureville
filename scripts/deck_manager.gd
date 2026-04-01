class_name Deck_Manager extends Node

@export var deck	: Deck

signal data_assigned

var cards_remaining    : Array = []
var dealt_hand         : Array = []
var discard_pile     : Array = []

func _ready() -> void:
	deck.intialize_deck_contents()
	cards_remaining = deck.Battle_Deck
	cards_remaining.shuffle()
func manage_deckout() -> void:
	if cards_remaining.size() < 5:
		discard_pile.shuffle()
		for card in range(discard_pile.size()):
			print(discard_pile[card].action_name)
			cards_remaining.append(discard_pile[card])
func apply_template(card: Node) -> void:
	card.card_data = cards_remaining[0]
	card.apply_template(card)
	dealt_hand.append(cards_remaining[0])
	cards_remaining.pop_front()

func clear_hand() -> void:
	for card in dealt_hand:
		discard_pile.append(card)
	dealt_hand.clear()
