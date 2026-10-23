class_name TurnTrackingManager extends Node

@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var enemy_manager: EnemyManager = $"../EnemyManager"

class TurnFlags:
	var took_damage_this_turn := false
	var took_damage_last_turn := false
	var sacrificed_this_turn := false
	var sacrificed_last_turn := false
	var gained_block_this_turn := false
	var gained_block_last_turn := false
	var gained_san_block_this_turn := false
	var gained_san_block_last_turn := false
	var healed_this_turn := false
	var healed_last_turn := false
	var cards_played_this_turn: Array[Card] = []
	var cards_played_last_turn: Array[Card] = []

var _entries: Dictionary = {}  # Stat_Manager -> TurnFlags
var _battle_tags: Dictionary = {}

func _ready() -> void:
	add_to_group("TurnTracker")   # lets cards find us without a scene path
	_register(player_stat_manager)
	enemy_manager.connect_and_catch_up(_on_enemy_registered)

	Events.card_played.connect(_on_card_played)
	Events.PlayerStandbyStart.connect(_on_player_turn_start.unbind(1))
	Events.EnemyStandbyStart.connect(_on_enemy_turn_start.unbind(1))

func _register(sm: Stat_Manager) -> void:
	if _entries.has(sm):
		return
	var flags := TurnFlags.new()
	_entries[sm] = flags
	# FIX: the player's real battle entity is sm.Player (a duplicate made in Stat_Manager),
	# not sm.Entity (the original resource). Signals on sm.Entity never fire during combat.
	# Enemies have no sm.Player, and their sm.Entity IS the live instance.
	var entity: BaseBattlerStats = sm.Player if sm.Player else sm.Entity
	entity.damage_taken.connect(_on_damage_taken.bind(sm))
	entity.hp_sacrificed.connect(_on_sacrificed.bind(sm))
	entity.block_gained.connect(_on_block_gained.bind(sm))
	entity.san_block_gained.connect(_on_san_block_gained.bind(sm))
	entity.health_restored.connect(_on_character_healed.bind(sm))

func _on_character_healed(_amount: int, _name: String, sm: Stat_Manager) -> void:
	_entries[sm].healed_this_turn = true
func _on_san_block_gained(_amount: int, _name: String, sm: Stat_Manager) -> void:
	_entries[sm].gained_san_block_this_turn = true

func _on_enemy_registered(view: EnemyView, sm: Stat_Manager) -> void:
	_register(sm)

func _on_damage_taken(_amount: int, _name: String, sm: Stat_Manager) -> void:
	_entries[sm].took_damage_this_turn = true

func _on_sacrificed(_amount: int, sm: Stat_Manager) -> void:
	_entries[sm].sacrificed_this_turn = true

func _on_block_gained(_amount: int, _name: String, sm: Stat_Manager) -> void:
	_entries[sm].gained_block_this_turn = true

func _on_card_played(card: Card) -> void:
	_entries[player_stat_manager].cards_played_this_turn.append(card)
	for tag in card.tags:
		_battle_tags[tag] = true

func _on_player_turn_start() -> void:
	_shift(_entries[player_stat_manager])

func played_tag_this_battle(tag: StringName) -> bool:
	return _battle_tags.has(tag)
func _on_enemy_turn_start() -> void:
	for sm in _entries:
		if sm != player_stat_manager:
			_shift(_entries[sm])
func count_tag_played_this_turn(tag: StringName) -> int:
	var count := 0
	for c in _entries[player_stat_manager].cards_played_this_turn:
		if c.tags.has(tag):
			count += 1
	return count
func _shift(f: TurnFlags) -> void:
	f.took_damage_last_turn = f.took_damage_this_turn
	f.took_damage_this_turn = false
	f.sacrificed_last_turn = f.sacrificed_this_turn
	f.sacrificed_this_turn = false
	f.gained_block_last_turn = f.gained_block_this_turn
	f.gained_block_this_turn = false
	f.cards_played_last_turn = f.cards_played_this_turn
	f.cards_played_this_turn = []
	f.healed_last_turn = f.healed_this_turn
	f.healed_this_turn = false
	f.gained_san_block_last_turn = f.gained_san_block_this_turn
	f.gained_san_block_this_turn = false

# ------------------------------------------------------------------ Orchestrate queries
# include_current = true while a card is resolving (card_played already recorded it),
# false when previewing a card that has not been played yet.

## Total cards played this turn (counts the card being resolved if include_current is on).
func count_cards_played_this_turn() -> int:
	return _entries[player_stat_manager].cards_played_this_turn.size()

## The card played immediately before the current one, or null if it is the first this turn.
func previous_card_this_turn(include_current: bool) -> Card:
	var played: Array[Card] = _entries[player_stat_manager].cards_played_this_turn
	var index := played.size() - (2 if include_current else 1)
	return played[index] if index >= 0 else null

## True if any card played earlier this turn (excluding the current one) was of this type.
func played_type_before(type: Card.Type, include_current: bool) -> bool:
	var played: Array[Card] = _entries[player_stat_manager].cards_played_this_turn
	var end := played.size() - (1 if include_current else 0)
	for i in range(end):
		if played[i].type == type:
			return true
	return false

# Query API for CardEffects
func took_damage_last_turn(sm: Stat_Manager) -> bool:
	return _entries.has(sm) and _entries[sm].took_damage_last_turn

func sacrificed_this_turn(sm: Stat_Manager) -> bool:
	return _entries.has(sm) and _entries[sm].sacrificed_this_turn

func sacrificed_last_turn(sm: Stat_Manager) -> bool:
	return _entries.has(sm) and _entries[sm].sacrificed_last_turn

func healed_last_turn(sm: Stat_Manager) -> bool:
	return _entries.has(sm) and _entries[sm].healed_last_turn

func gained_block_last_turn(sm: Stat_Manager) -> bool:
	return _entries.has(sm) and _entries[sm].gained_block_last_turn

func gained_san_block_last_turn(sm: Stat_Manager) -> bool:
	return _entries.has(sm) and _entries[sm].gained_san_block_last_turn

func played_type_this_turn(type: Card.Type) -> bool:
	for c in _entries[player_stat_manager].cards_played_this_turn:
		if c.type == type:
			return true
	return false

func played_type_last_turn(type: Card.Type) -> bool:
	for c in _entries[player_stat_manager].cards_played_last_turn:
		if c.type == type:
			return true
	return false
