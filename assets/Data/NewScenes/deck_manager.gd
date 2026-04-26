class_name DeckManager extends Node
@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var targeting_area: Node2D = $"../../Node2D_Layer/TargetingArea"
@onready var label_0: Label = $"../../Node2D_Layer/DiscardPile/Label"
@onready var label_1: Label = $"../../Node2D_Layer/DeckPile/Label"
var CardDeck : Deck
var CardsDiscarded : int : set = set_cards_discarded
var CardsInDeck: int : set = set_cards_still_in_deck

func _ready() -> void:
	if not Events.card_played.is_connected(player_stat_manager.Player.starting_deck.card_played):
		Events.card_played.connect(player_stat_manager.Player.starting_deck.card_played)
		Events.PlayerBattleEnd.connect(on_Player_end_turn)
		Events.PlayerBattleStart.connect(on_Player_battle_start) # FIX 4: dedicated handler
		player_stat_manager.Player.starting_deck.DeckSize_Changed.connect(track_deck_size)
		player_stat_manager.Player.starting_deck.DiscardSize_Changed.connect(set_cards_discarded) # NEW

	CardDeck = player_stat_manager.Player.starting_deck

func on_Player_battle_start(_turn: Variant = null) -> void: # FIX 4: shuffle once here
	CardDeck.shuffle_deck()
	update_tracked_cards()

func ready_card_drawn() -> CardUI:
	# FIX 4: shuffle removed from here
	var CardData = CardDeck.draw_card()
	var CardScene = preload("res://assets/Data/NewScenes/Cards/card.tscn").instantiate()
	var start_pos = Vector2(800, 0)
	CardScene.global_position = start_pos
	CardScene.parent = targeting_area
	CardScene.player_stats = player_stat_manager.Player
	CardScene.card_data = CardData
	return CardScene

func update_tracked_cards() -> void:
	set_cards_discarded(CardDeck.Discard_Pile.size())
	set_cards_still_in_deck(CardDeck.Battle_Deck.size())

func set_cards_discarded(amount) -> void:
	CardsDiscarded = amount
	label_0.text = str(CardsDiscarded)


func track_deck_size(deck_size: int) -> void:
	CardsInDeck = CardDeck.Battle_Deck.size()

func set_cards_still_in_deck(amount) -> void:
	CardsInDeck = amount
	label_1.text = str(CardsInDeck)

func on_Player_end_turn(_turn : Variant) -> void:
	CardDeck.discard_hand()
