class_name ActiveEffectManager extends Node

@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var enemy_manager: EnemyManager = $"../EnemyManager"
@onready var player_view: PlayerView = $"../../Control_Layer/Control_Base/Base_Margin/MarginContainer/PlayerView"
@onready var phase_manager: PhaseManager = $"../PhaseManager"

const EFFECT_DISPLAY_DURATION: float = 2.0
const ENEMY_TICK_DELAY: float = 0.3

class EffectDisplayEntry:
	var stat_manager: Stat_Manager
	var icon: TextureRect
	var label: Label
	var get_effects: Callable
	var index: int = 0
	var hovered: bool = false

	func _init(sm: Stat_Manager, icon_: TextureRect, label_: Label, get_effects_: Callable) -> void:
		stat_manager = sm
		icon = icon_
		label = label_
		get_effects = get_effects_

var _entries: Dictionary = {}          # Stat_Manager -> EffectDisplayEntry
var _entry_order: Array[Stat_Manager] = []
var _effect_cycle_timer: Timer


func _ready() -> void:
	_setup_effect_cycle_timer()
	_register_player()
	enemy_manager.connect_and_catch_up(_on_enemy_registered)
	enemy_manager.enemy_unregistered.connect(_on_enemy_unregistered)

	Events.PlayerBattleEnd.connect(_on_player_battle_end.unbind(1))
	Events.EnemyBattleEnd.connect(_on_enemy_battle_end.unbind(1))
	Events.effect_applied.connect(display_active_effects)
	Events.effect_display.connect(DamageNumbers.display_effect)
	Events.StatusWoreOff.connect(_track_removal_effects)

func _setup_effect_cycle_timer() -> void:
	_effect_cycle_timer = Timer.new()
	_effect_cycle_timer.wait_time = EFFECT_DISPLAY_DURATION
	_effect_cycle_timer.autostart = true
	_effect_cycle_timer.timeout.connect(_on_effect_cycle_tick)
	add_child(_effect_cycle_timer)


func _register_player() -> void:
	var entry := EffectDisplayEntry.new(
		player_stat_manager,
		player_view.player_bars_container.statuseffecticon,
		player_view.player_bars_container.turns_remaining,
		func(): return player_stat_manager.Player.ActiveEffects
	)
	_add_entry(player_stat_manager, entry)


func _on_enemy_registered(view: EnemyView, stat_manager: Stat_Manager) -> void:
	if _entries.has(stat_manager):
		return
	var entry := EffectDisplayEntry.new(
		stat_manager,
		view.enemy_bars_container.statuseffecticon,
		view.enemy_bars_container.turns_remaining,
		func(): return stat_manager.Entity.ActiveEffects
	)
	_add_entry(stat_manager, entry)


func _add_entry(stat_manager: Stat_Manager, entry: EffectDisplayEntry) -> void:
	_entries[stat_manager] = entry
	_entry_order.append(stat_manager)
	entry.icon.mouse_entered.connect(_on_icon_hover.bind(stat_manager, true))
	entry.icon.mouse_exited.connect(_on_icon_hover.bind(stat_manager, false))


func _on_enemy_unregistered(_view: EnemyView, stat_manager: Stat_Manager) -> void:
	if stat_manager and _entries.has(stat_manager):
		_entries.erase(stat_manager)
		_entry_order.erase(stat_manager)


func _on_icon_hover(stat_manager: Stat_Manager, hovered: bool) -> void:
	if _entries.has(stat_manager):
		_entries[stat_manager].hovered = hovered
	_check_pause_timer()


func _check_pause_timer() -> void:
	for entry in _entries.values():
		if entry.hovered:
			_effect_cycle_timer.paused = true
			return
	_effect_cycle_timer.paused = false


func _on_effect_cycle_tick() -> void:
	for stat_manager in _entry_order:
		_advance_entry(_entries[stat_manager])


func _advance_entry(entry: EffectDisplayEntry) -> void:
	var effects: Array = entry.get_effects.call().filter(func(e): return e != null)

	if effects.is_empty():
		entry.icon.texture = null
		entry.label.text = ""
		return

	entry.index = entry.index % effects.size()
	var effect = effects[entry.index]

	if effects.size() == 1:
		entry.icon.texture = effect.status_icon
		entry.label.text = str(effect.current_duration)
	else:
		_tween_icon_swap(entry.icon, entry.label, effect)

	entry.index = (entry.index + 1) % effects.size()


func _tween_icon_swap(icon: TextureRect, label: Label, effect: Resource) -> void:
	var tween := create_tween()
	tween.tween_property(icon, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func():
		icon.texture = effect.status_icon
		label.text = str(effect.current_duration)
	)
	tween.tween_property(icon, "modulate:a", 1.0, 0.15)


func display_active_effects() -> void:
	for stat_manager in _entry_order:
		_entries[stat_manager].index = 0
	_on_effect_cycle_tick()

########################################################################

func tick_effects(stat_manager: Stat_Manager) -> void:
	var target_stats
	var target_array: Array

	if stat_manager.Entity is CharacterInstance:
		target_stats = stat_manager.Player
		target_array = stat_manager.Player.ActiveEffects
	elif stat_manager.Entity is EnemyBattlerStats:
		target_stats = stat_manager.Entity
		target_array = stat_manager.Entity.ActiveEffects
	else:
		return

	for i in range(target_array.size() - 1, -1, -1):
		var effect = target_array[i]
		if effect is StatusEffect:
			effect.on_tick(target_stats)
			if effect.current_duration <= 0 and target_array.has(effect):
				effect.on_remove(target_stats)

	display_active_effects()


func _on_player_battle_end() -> void:
	tick_effects(player_stat_manager)
	phase_manager.advance_to_next_phase()


func _on_enemy_battle_end() -> void:
	await _tick_enemies_sequentially()
	phase_manager.advance_to_next_phase()


func _tick_enemies_sequentially() -> void:
	var enemies := _entry_order.filter(func(sm): return sm != player_stat_manager)
	for i in enemies.size():
		tick_effects(enemies[i])
		if i < enemies.size() - 1:
			await get_tree().create_timer(ENEMY_TICK_DELAY, true, false, false).timeout

func _track_removal_effects(effect: StatusEffect, Entity: BaseBattlerStats) -> void:
	for stat_manager in enemy_manager._view_to_stat_manager.values():
		if stat_manager is Stat_Manager:
			if stat_manager.Entity == Entity and effect not in stat_manager.Entity.ActiveEffects:
				if effect is Concussed:
					stat_manager.EnemyThoughts.enable_attacks()
