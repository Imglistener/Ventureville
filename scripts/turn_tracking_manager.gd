class_name TurnTrackingManager extends Node

@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var enemy_manager: EnemyManager = $"../EnemyManager"

class TurnFlags:
	var took_damage_this_turn := false
	var took_damage_last_turn := false
	var gained_block_this_turn := false
	var gained_block_last_turn := false
	var gained_san_block_this_turn := false
	var gained_san_block_last_turn := false
	var healed_this_turn := false
	var healed_last_turn := false
	var cards_played_this_turn: Array[Card] = []
	var cards_played_last_turn: Array[Card] = []

var _entries: Dictionary = {}  # Stat_Manager -> TurnFlags

func _ready() -> void:
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
	sm.Entity.damage_taken.connect(_on_damage_taken.bind(sm))
	sm.Entity.block_gained.connect(_on_block_gained.bind(sm))
	sm.Entity.san_block_gained.connect(_on_san_block_gained.bind(sm))
	sm.Entity.health_restored.connect(_on_character_healed.bind(sm))

func _on_character_healed(_amount: int, _name: String, sm: Stat_Manager) -> void:
	_entries[sm].healed_this_turn = true
func _on_san_block_gained(_amount: int, _name: String, sm: Stat_Manager) -> void:
	_entries[sm].gained_san_block_this_turn = true

func _on_enemy_registered(view: EnemyView, sm: Stat_Manager) -> void:
	_register(sm)

func _on_damage_taken(_amount: int, _name: String, sm: Stat_Manager) -> void:
	_entries[sm].took_damage_this_turn = true

func _on_block_gained(_amount: int, _name: String, sm: Stat_Manager) -> void:
	_entries[sm].gained_block_this_turn = true

func _on_card_played(card: Card) -> void:
	_entries[player_stat_manager].cards_played_this_turn.append(card)

func _on_player_turn_start() -> void:
	_shift(_entries[player_stat_manager])

func _on_enemy_turn_start() -> void:
	for sm in _entries:
		if sm != player_stat_manager:
			_shift(_entries[sm])

func _shift(f: TurnFlags) -> void:
	f.took_damage_last_turn = f.took_damage_this_turn
	f.took_damage_this_turn = false
	f.gained_block_last_turn = f.gained_block_this_turn
	f.gained_block_this_turn = false
	f.cards_played_last_turn = f.cards_played_this_turn
	f.cards_played_this_turn = []
	f.healed_last_turn = f.healed_this_turn
	f.healed_this_turn = false
	f.gained_san_block_last_turn = f.gained_san_block_this_turn
	f.gained_san_block_this_turn = false

# Query API for CardEffects
func took_damage_last_turn(sm: Stat_Manager) -> bool:
	return _entries.has(sm) and _entries[sm].took_damage_last_turn

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
