class_name Stat_Manager extends Node
@onready var enemy: EnemyView = $"../../Control_Layer/Enemy"
@export var Entity : BaseBattlerStats
@onready var player_view: PlayerView = $"../../Control_Layer/Control_Base/Base_Margin/MarginContainer/PlayerView"
@onready var Resources: resource_manager = $"../ResourceManager"
@onready var phase_manager: PhaseManager = $"../PhaseManager"
@onready var bgm: AudioStreamPlayer = $"../../BGM"
@onready var log: Log = $"../../Control_Layer/Control_Base/ColorRect/MarginContainer/ScrollContainer/Log"
@onready var deck_manager: DeckManager = $"../DeckManager"

@export var enemy_ai: PackedScene 
var Player: CharacterInstance
var EnemyThoughts: EnemyAI
var CurrentAction : EnemyAction : set = set_current_action

func  set_current_action(value: EnemyAction) -> void:
	CurrentAction = value

func _ready() -> void:
	if Entity != null:
		_initialize_entity(Entity.Battler_Type)
	Events.EnemyActionCompleted.connect(_on_enemy_action_completed)
	Events.EnemyBattleStart.connect(play_turn.unbind(1))
	Events.EnemyStandbyStart.connect(update_action.unbind(1))
	if not Events.EnemyActionReady.is_connected(phase_manager.advance_to_next_phase):
		Events.EnemyActionReady.connect(phase_manager.advance_to_next_phase)
	if not Events.EnemyStandbyEnd.is_connected(phase_manager.advance_to_next_phase):
		Events.EnemyStandbyEnd.connect(phase_manager.advance_to_next_phase.unbind(1))
	if Events.PlayerStandbyStart.is_connected(_reset_block):
		Events.PlayerStandbyStart.disconnect(_reset_block)
	if Events.EnemyStandbyStart.is_connected(_reset_block):
		Events.EnemyStandbyStart.disconnect(_reset_block)
	if Entity.Battler_Type == Entity.BATTLER_TYPES.PLAYER:
		Events.PlayerStandbyStart.connect(_reset_block.unbind(1))
	elif Entity.Battler_Type == Entity.BATTLER_TYPES.ENEMY:
		Events.EnemyStandbyStart.connect(_reset_block.unbind(1))

func _reset_block() -> void:
	if Entity is EnemyBattlerStats:
		Entity.reset_block()
		Entity.Stats_Changed.emit()
	elif Player != null:
		Player.reset_block()
		Player.Stats_Changed.emit()
		
func setup_ai() -> void:
	if Entity is not EnemyBattlerStats: return
	if EnemyThoughts:
		EnemyThoughts.queue_free()
	var EnemyThoughtsNew: EnemyAI = enemy_ai.instantiate()
	add_child(EnemyThoughtsNew)
	EnemyThoughts = EnemyThoughtsNew
	EnemyThoughts.enemy = enemy
	EnemyThoughts.target = self

	
func update_action() -> void:
	if Entity is not EnemyBattlerStats: return
	if not EnemyThoughts:
		return
	if not CurrentAction:
		CurrentAction = EnemyThoughts.get_action()

	var conditional_action_active := EnemyThoughts.get_conditional_action()
	if conditional_action_active and CurrentAction != conditional_action_active:
		CurrentAction = conditional_action_active
	if CurrentAction:
		Events.EnemyActionReady.emit()


func _initialize_entity(entity_type: Variant) -> void:
	if entity_type == Entity.BATTLER_TYPES.ENEMY:
		Entity = Entity.create_instance()
		if not enemy.is_node_ready():
			await enemy.ready
		enemy.Enemy = self
		log.connect_to_entity(Entity)
		setup_ai()
		enemy.update_enemy_view(Entity.Battler_Art_Normal, Entity.Battler_Art_Hovered)
		Entity.damage_numbers = get_tree().get_nodes_in_group("DamageNumbers")[1].global_position
		enemy.enemy_hp.max_value = Entity.Max_HP
		enemy.enemy_hp.value	= Entity.current_health
		enemy.enemy_san.max_value	= Entity.Max_SAN
		enemy.enemy_san.value	= Entity.current_sanity
		enemy.enemy_hp_counter.text = str(Entity.current_health)
		enemy.enemy_san_counter.text = str(Entity.current_sanity)
		enemy.enemy_shield.max_value = Entity.current_block + 1
		enemy.enemy_shield.value = Entity.current_block
		enemy.enemy_san_shield.max_value	= Entity.current_san_block	+ 1
		enemy.enemy_san_shield.value	= Entity.current_san_block
		
	if entity_type == Entity.BATTLER_TYPES.PLAYER:
		if not player_view.is_node_ready():
			await player_view.ready
		Player = Entity.Load_Player()
		
		Player.starting_deck.intialize_deck_contents()
		Player.damage_numbers = get_tree().get_nodes_in_group("DamageNumbers")[0].global_position
		log.connect_to_entity(Player)
		player_view.player_bars_container.player_hp.max_value = Player.Max_HP
		player_view.player_bars_container.player_hp.value = Player.current_health
		player_view.player_bars_container.player_hp_counter.text = str(Player.current_health)
		player_view.player_bars_container.player_san.max_value = Player.Max_SAN
		player_view.player_bars_container.player_san.value = Player.current_sanity
		player_view.player_bars_container.player_san_counter.text = str(Player.current_sanity)
		player_view.player_bars_container.player_shield.max_value = Player.current_block+1
		player_view.player_bars_container.player_shield.value = Player.current_block
		player_view.player_bars_container.player_san_shield.max_value = Player.current_san_block+1
		player_view.player_bars_container.player_san_shield.value = Player.current_san_block
		player_view.player_portrait.texture = Player.player_portrait
	

func phase_transition() -> void:
	var phase_music: AudioStream
	var actionlibrary = EnemyThoughts.get_children()
	for action in actionlibrary:
		if action.ActionEffect == EnemyAction.ActionEffects.Transition:
			if action.Phases:
				phase_music = action.Phases[action.phase_index - 1].PhaseBGM
	EnemyThoughts.setup_action_chances()
	bgm.stream = phase_music
	bgm.play()

func play_turn() -> void:
	if Entity is not EnemyBattlerStats: return
	if enemy.enemy_view.has_node("Idle"):
		enemy.enemy_view.get_node("Idle").stop()
	if not CurrentAction:
		return
	CurrentAction.use_action()
	CurrentAction = null
	var end = func():
		if enemy.enemy_view.has_node("Idle"):
			enemy.enemy_view.get_node("Idle").start(enemy.enemy_view)
	Events.EnemyActionCompleted.connect(
		end.unbind(1)
	)


func _on_enemy_action_completed(_enemy: EnemyAction) -> void:
	if Entity is not EnemyBattlerStats: return
	await get_tree().create_timer(0.5, true, false, false).timeout
	phase_manager.advance_to_next_phase()
