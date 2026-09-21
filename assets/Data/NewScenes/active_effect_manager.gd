class_name ActiveEffectManager extends Node

@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var enemy_manager: EnemyManager = $"../EnemyManager"
@onready var player_view: PlayerView = $"../../Control_Layer/Control_Base/Base_Margin/MarginContainer/PlayerView"
@onready var phase_manager: PhaseManager = $"../PhaseManager"
@export var tooltip : PackedScene
@export var condition_tooltip: PackedScene

const EFFECT_DISPLAY_DURATION: float = 2.0
const ENEMY_TICK_DELAY: float = 0.3


class ConditionDisplayEntry:
	var stat_manager: Stat_Manager
	var icon: TextureRect
	var get_conditions: Callable
	var index: int = 0
	var hovered: bool = false
	var current_condition: BattleCondition
	func _init(sm: Stat_Manager, icon_: TextureRect, get_conditions_: Callable) -> void:
		stat_manager = sm
		icon = icon_
		get_conditions = get_conditions_

var _condition_entries: Dictionary = {}       # Stat_Manager -> ConditionDisplayEntry
var _condition_entry_order: Array[Stat_Manager] = []


class EffectDisplayEntry:
	var stat_manager: Stat_Manager
	var icon: TextureRect
	var label: Label
	var get_effects: Callable
	var index: int = 0
	var hovered: bool = false
	var current_effect: StatusEffect
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
	_register_player_conditions()
	enemy_manager.connect_and_catch_up(_on_enemy_registered)
	enemy_manager.enemy_unregistered.connect(_on_enemy_unregistered)

	Events.PlayerBattleEnd.connect(_on_player_battle_end.unbind(1))
	Events.EnemyBattleEnd.connect(_on_enemy_battle_end.unbind(1))
	Events.effect_applied.connect(display_active_effects)
	Events.effect_display.connect(StatusLabels.display_effect)
	Events.StatusWoreOff.connect(_track_removal_effects)
	Events.BattleConditionActivated.connect(_on_condition_changed.unbind(2))
	Events.BattleConditionExpired.connect(_on_condition_changed.unbind(2))


func _setup_effect_cycle_timer() -> void:
	_effect_cycle_timer = Timer.new()
	_effect_cycle_timer.wait_time = EFFECT_DISPLAY_DURATION
	_effect_cycle_timer.autostart = true
	_effect_cycle_timer.timeout.connect(_on_effect_cycle_tick)
	add_child(_effect_cycle_timer)


############################### STATUS EFFECTS ###############################

func _register_player() -> void:
	var entry := EffectDisplayEntry.new(
		player_stat_manager,
		player_view.player_bars_container.statuseffecticon,
		player_view.player_bars_container.turns_remaining,
		func(): return player_stat_manager.Player.ActiveEffects
	)
	_add_entry(player_stat_manager, entry)


func _add_entry(stat_manager: Stat_Manager, entry: EffectDisplayEntry) -> void:
	_entries[stat_manager] = entry
	_entry_order.append(stat_manager)
	entry.icon.mouse_entered.connect(_on_icon_hover.bind(stat_manager, true))
	entry.icon.mouse_exited.connect(_on_icon_hover.bind(stat_manager, false))


func _on_icon_hover(stat_manager: Stat_Manager, hovered: bool) -> void:
	if _entries.has(stat_manager):
		var entry := _entries[stat_manager] as EffectDisplayEntry
		entry.hovered = hovered
		if hovered and entry.current_effect:
			var tooltip_scene = tooltip.instantiate() as StatusEffectTooltip
			tooltip_scene.displayed_status = entry.current_effect
			if stat_manager.Entity is EnemyBattlerStats:
				var view = enemy_manager._view_to_stat_manager.find_key(stat_manager)
				view.status_tooltip_marker.add_child(tooltip_scene)
			else:
				var view = stat_manager.player_view as PlayerView
				view.status_effect_marker.add_child(tooltip_scene)
			tooltip_scene.show_tooltip()
			tooltip_scene.z_index = 5
		elif not hovered and entry.current_effect:
			clear_tooltips(stat_manager)

	_check_pause_timer()


func clear_tooltips(stat_manager: Stat_Manager) -> void:
	if stat_manager.Entity is EnemyBattlerStats:
		var enemy_view = enemy_manager._view_to_stat_manager.find_key(stat_manager) as EnemyView
		if not enemy_view:
			return
		for child in enemy_view.status_tooltip_marker.get_children():
			if not child:
				continue
			if child is StatusEffectTooltip:
				child.queue_free()
	else:
		for child in player_view.status_effect_marker.get_children():
			if not child:
				continue
			if child is StatusEffectTooltip:
				child.queue_free()


func _check_pause_timer() -> void:
	for entry in _entries.values():
		if entry.hovered:
			_effect_cycle_timer.paused = true
			return
	for entry in _condition_entries.values():
		if entry.hovered:
			_effect_cycle_timer.paused = true
			return
	_effect_cycle_timer.paused = false


func _advance_entry(entry: EffectDisplayEntry) -> void:
	var effects: Array = entry.get_effects.call().filter(func(e): return e != null)

	if effects.is_empty():
		entry.icon.texture = null
		entry.label.text = ""
		entry.current_effect = null
		return

	entry.index = entry.index % effects.size()
	var effect = effects[entry.index]
	entry.current_effect = effect
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


func _track_removal_effects(effect: StatusEffect, Entity: BaseBattlerStats) -> void:
	for stat_manager in enemy_manager._view_to_stat_manager.values():
		if stat_manager is Stat_Manager:
			if stat_manager.Entity == Entity and effect not in stat_manager.Entity.ActiveEffects:
				if effect is Concussed:
					stat_manager.EnemyThoughts.enable_attacks()


############################### BATTLE CONDITIONS ###############################

func _register_player_conditions() -> void:
	var entry := ConditionDisplayEntry.new(
		player_stat_manager,
		player_view.player_bars_container.perma_buff_icon,
		func(): return player_stat_manager.Player.BattleConditions
	)
	_add_condition_entry(player_stat_manager, entry)


func _add_condition_entry(stat_manager: Stat_Manager, entry: ConditionDisplayEntry) -> void:
	_condition_entries[stat_manager] = entry
	_condition_entry_order.append(stat_manager)
	entry.icon.mouse_entered.connect(_on_condition_icon_hover.bind(stat_manager, true))
	entry.icon.mouse_exited.connect(_on_condition_icon_hover.bind(stat_manager, false))


func _on_condition_icon_hover(stat_manager: Stat_Manager, hovered: bool) -> void:
	if not _condition_entries.has(stat_manager):
		return
	var entry := _condition_entries[stat_manager] as ConditionDisplayEntry
	entry.hovered = hovered
	if hovered and entry.current_condition:
		var tooltip_scene = condition_tooltip.instantiate() as BattleConditionTooltip
		tooltip_scene.displayed_condition = entry.current_condition
		if stat_manager.Entity is EnemyBattlerStats:
			var view = enemy_manager._view_to_stat_manager.find_key(stat_manager)
			view.condition_effect_marker.add_child(tooltip_scene)
		else:
			player_view.condition_effect_marker.add_child(tooltip_scene)
		tooltip_scene.show_tooltip()
		tooltip_scene.z_index = 5
	elif not hovered and entry.current_condition:
		clear_condition_tooltips(stat_manager)

	_check_pause_timer()


func clear_condition_tooltips(stat_manager: Stat_Manager) -> void:
	if stat_manager.Entity is EnemyBattlerStats:
		var enemy_view = enemy_manager._view_to_stat_manager.find_key(stat_manager) as EnemyView
		if not enemy_view:
			return
		for child in enemy_view.condition_effect_marker.get_children():
			if not child:
				continue
			if child is BattleConditionTooltip:
				child.queue_free()
	else:
		for child in player_view.condition_effect_marker.get_children():
			if not child:
				continue
			if child is BattleConditionTooltip:
				child.queue_free()


func _advance_condition_entry(entry: ConditionDisplayEntry) -> void:
	var conditions: Array = entry.get_conditions.call().filter(func(c): return c != null)

	if conditions.is_empty():
		entry.icon.texture = null
		entry.icon.visible = false
		entry.current_condition = null
		return

	entry.icon.visible = true
	entry.index = entry.index % conditions.size()
	var condition: BattleCondition = conditions[entry.index]
	entry.current_condition = condition
	if conditions.size() == 1:
		entry.icon.texture = condition.condition_icon
	else:
		_tween_condition_icon_swap(entry.icon, condition)

	entry.index = (entry.index + 1) % conditions.size()


func _tween_condition_icon_swap(icon: TextureRect, condition: BattleCondition) -> void:
	var tween := create_tween()
	tween.tween_property(icon, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func():
		icon.texture = condition.condition_icon
	)
	tween.tween_property(icon, "modulate:a", 1.0, 0.15)


func _on_condition_changed() -> void:
	for stat_manager in _condition_entry_order:
		_condition_entries[stat_manager].index = 0
		_advance_condition_entry(_condition_entries[stat_manager])


func tick_conditions(stat_manager: Stat_Manager) -> void:
	var battle_conditions: Array

	if stat_manager.Entity is CharacterInstance:
		battle_conditions = stat_manager.Player.BattleConditions
	elif stat_manager.Entity is EnemyBattlerStats:
		battle_conditions = stat_manager.Entity.BattleConditions
	else:
		return

	var enemy_targets: Array[Node] = enemy_manager.get_enemy_views()
	var player_target: Array[Node] = [stat_manager]
	var targets = enemy_targets + player_target

	# Iterate backwards: trigger_once conditions may erase themselves mid-loop
	for i in range(battle_conditions.size() - 1, -1, -1):
		var condition: BattleCondition = battle_conditions[i]
		if condition.is_condition_passive():
			condition.on_tick(targets)
		elif condition.is_condition_active():
			if condition.on_conditions_met(targets):
				condition.on_trigger(targets)
				if condition.trigger_once:
					condition.on_expired(targets)


############################### SHARED REGISTRATION / TIMER ###############################

func _on_enemy_registered(view: EnemyView, stat_manager: Stat_Manager) -> void:
	if not _entries.has(stat_manager):
		var entry := EffectDisplayEntry.new(
			stat_manager,
			view.enemy_bars_container.statuseffecticon,
			view.enemy_bars_container.turns_remaining,
			func(): return stat_manager.Entity.ActiveEffects
		)
		_add_entry(stat_manager, entry)

	if not _condition_entries.has(stat_manager):
		var condition_entry := ConditionDisplayEntry.new(
			stat_manager,
			view.enemy_bars_container.perma_buff_icon,
			func(): return stat_manager.Entity.BattleConditions
		)
		_add_condition_entry(stat_manager, condition_entry)


func _on_enemy_unregistered(_view: EnemyView, stat_manager: Stat_Manager) -> void:
	if stat_manager and _entries.has(stat_manager):
		_entries.erase(stat_manager)
		_entry_order.erase(stat_manager)
	if stat_manager and _condition_entries.has(stat_manager):
		_condition_entries.erase(stat_manager)
		_condition_entry_order.erase(stat_manager)


func _on_effect_cycle_tick() -> void:
	for stat_manager in _entry_order:
		_advance_entry(_entries[stat_manager])
	for stat_manager in _condition_entry_order:
		_advance_condition_entry(_condition_entries[stat_manager])


func _on_player_battle_end() -> void:
	tick_effects(player_stat_manager)
	tick_conditions(player_stat_manager)
	phase_manager.advance_to_next_phase()


func _on_enemy_battle_end() -> void:
	await _tick_enemies_sequentially()
	phase_manager.advance_to_next_phase()


func _tick_enemies_sequentially() -> void:
	var enemies := _entry_order.filter(func(sm): return sm != player_stat_manager)
	for i in enemies.size():
		tick_effects(enemies[i])
		tick_conditions(enemies[i])
		if i < enemies.size() - 1:
			await get_tree().create_timer(ENEMY_TICK_DELAY, true, false, false).timeout
