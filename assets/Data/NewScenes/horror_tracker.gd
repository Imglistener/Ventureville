class_name HorrorTracker extends Node
## Gives Horrified out for the two passive rules:
##  Breaking Point: one instance of SAN damage (after SAN Shield) of at least
##    breaking_point_fraction of the target's Max SAN adds breaking_point_stacks.
##  Hollow Mind: starting your turn at 0 SAN for hollow_mind_turns turns in a row
##    adds hollow_mind_stacks, then the counter resets.
## Add as a child of BattleScene/Functionality, next to TurnTrackingManager.

const HORRIFIED_RES := preload("res://assets/Status Effects/Debuffs/Horrified.tres")

@export_range(0.05, 1.0) var breaking_point_fraction := 0.2
@export var breaking_point_stacks := 2
@export var hollow_mind_turns := 3
@export var hollow_mind_stacks := 3

@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var enemy_manager: EnemyManager = $"../EnemyManager"

var _zero_turns: Dictionary = {}   # Stat_Manager -> consecutive turns started at 0 SAN


func _ready() -> void:
	add_to_group("HorrorTracker")
	Events.PlayerStandbyStart.connect(_on_player_standby.unbind(1))
	Events.EnemyStandbyStart.connect(_on_enemy_standby.unbind(1))
	enemy_manager.connect_and_catch_up(_on_enemy_registered)
	enemy_manager.enemy_unregistered.connect(_on_enemy_unregistered)
	_register_player()


func _register_player() -> void:
	# Stat_Manager builds the player's live instance after awaiting the view.
	while player_stat_manager.Player == null:
		await get_tree().process_frame
	_register(player_stat_manager, player_stat_manager.Player)


func _on_enemy_registered(_view: EnemyView, sm: Stat_Manager) -> void:
	_register(sm, sm.Entity)


func _on_enemy_unregistered(_view: EnemyView, sm: Stat_Manager) -> void:
	_zero_turns.erase(sm)


func _register(sm: Stat_Manager, entity: BaseBattlerStats) -> void:
	if _zero_turns.has(sm):
		return
	_zero_turns[sm] = 0
	entity.sanity_damage_taken.connect(_on_sanity_damage.bind(sm, entity))


func _on_sanity_damage(amount: int, _name: String, sm: Stat_Manager, entity: BaseBattlerStats) -> void:
	if amount >= entity.Max_SAN * breaking_point_fraction:
		_horrify(sm, entity, breaking_point_stacks)


func _on_player_standby() -> void:
	_check_hollow_mind(player_stat_manager, player_stat_manager.Player)


func _on_enemy_standby() -> void:
	for view in enemy_manager.get_enemy_views():
		var sm := enemy_manager.get_stat_manager_for(view)
		if sm:
			_check_hollow_mind(sm, sm.Entity)


func _check_hollow_mind(sm: Stat_Manager, entity: BaseBattlerStats) -> void:
	if not entity or not _zero_turns.has(sm):
		return
	if entity.current_sanity > 0:
		_zero_turns[sm] = 0
		return
	_zero_turns[sm] += 1
	if _zero_turns[sm] >= hollow_mind_turns:
		_zero_turns[sm] = 0
		_horrify(sm, entity, hollow_mind_stacks)


func _horrify(sm: Stat_Manager, entity: BaseBattlerStats, stacks: int) -> void:
	if entity.current_health <= 0:
		return
	var node: Node = sm if entity is CharacterInstance else sm.enemy
	if not is_instance_valid(node):
		return
	var targets: Array[Node] = [node]
	HORRIFIED_RES.on_apply(targets, stacks)
