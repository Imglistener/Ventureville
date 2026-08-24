class_name Stat_Manager extends Node

signal EntityStatsChanged(view: EnemyView, stat_manager: Stat_Manager)
signal EntityDied(view: EnemyView, stat_manager: Stat_Manager) 

var _is_dead: bool = false
@export var enemy: EnemyView
@export var Entity : BaseBattlerStats
@onready var player_view: PlayerView = $"../../Control_Layer/Control_Base/Base_Margin/MarginContainer/PlayerView"
@onready var Resources: resource_manager = $"../ResourceManager"
@onready var phase_manager: PhaseManager = $"../PhaseManager"
@onready var bgm: AudioStreamPlayer = $"../../BGM"
@onready var log: Log = $"../../Control_Layer/Control_Base/ColorRect/MarginContainer/ScrollContainer/Log"
@onready var deck_manager: DeckManager = $"../DeckManager"
@onready var items_menu: ItemsMenu = $"../../Control_Layer/Control_Base/ItemsMenu"
@onready var enemy_manager: Node = $"../EnemyManager"

@export var enemy_ai: PackedScene 
var Player: CharacterInstance
var EnemyThoughts: EnemyAI
var CurrentAction : EnemyAction : set = set_current_action

func  set_current_action(value: EnemyAction) -> void:
	CurrentAction = value

func _ready() -> void:
	if Entity != null:
		_initialize_entity(Entity.Battler_Type)

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
	if _is_dead: return
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
		enemy_manager.register(enemy, self)
		if not Entity.Stats_Changed.is_connected(_on_entity_stats_changed):
			Entity.Stats_Changed.connect(_on_entity_stats_changed)
		log.connect_to_entity(Entity)
		setup_ai()
		enemy.update_enemy_view(Entity.Battler_Art_Normal, Entity.Battler_Art_Hovered)
		Entity.damage_numbers = enemy.dmg_numbers.global_position
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
		if not Player.Stats_Changed.is_connected(_on_player_stats_changed):
			Player.Stats_Changed.connect(_on_player_stats_changed)
		items_menu.player_inventory = Player.player_inventory
		items_menu.display_items_and_quantities()
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
	if _is_dead: return
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
		end.unbind(1), CONNECT_ONE_SHOT
	)

func _on_entity_stats_changed() -> void:
	EntityStatsChanged.emit(enemy, self)
	if not _is_dead and Entity is EnemyBattlerStats and Entity.current_health <= 0:
		_is_dead = true
		_handle_enemy_death()

func _on_player_stats_changed() -> void:
	EntityStatsChanged.emit(null, self)
	if not _is_dead and Player.current_health <= 0:
		_is_dead = true
		_handle_player_death()

func _handle_enemy_death() -> void:
	CurrentAction = null
	enemy.enemy_view.disabled = true
	await enemy.play_death_animation()
	enemy_manager.unregister(enemy)
	enemy.visible = false
	EntityDied.emit(enemy, self)

func _handle_player_death() -> void:
	# swap in a player death animation call here if/when one exists
	EntityDied.emit(null, self)
