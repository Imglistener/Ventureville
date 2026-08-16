class_name ActiveEffectManager extends Node

@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var enemy_manager: EnemyManager = $"../EnemyManager"
@onready var player_view: PlayerView = $"../../Control_Layer/Control_Base/Base_Margin/MarginContainer/PlayerView"
@onready var phase_manager: PhaseManager = $"../PhaseManager"

var _effect_cycle_timer: Timer
var _player_effect_index: int = 0
var _is_player_icon_hovered: bool = false
const EFFECT_DISPLAY_DURATION: float = 2.0
const ENEMY_TICK_DELAY: float = 0.3  # pacing gap between each enemy's tick, sequential feel

# Per-enemy state, keyed by Stat_Manager. Replaces the old single
# enemy/enemy_stat_manager/_enemy_effect_index/_is_enemy_icon_hovered fields.
# entry shape: { "view": EnemyView, "index": int, "hovered": bool }
var _enemy_entries: Dictionary = {}
var _enemy_order: Array[Stat_Manager] = []


func _ready() -> void:
	_setup_effect_cycle_timer()
	_connect_player_icon_hover_signal()

	enemy_manager.connect_and_catch_up(_on_enemy_registered)
	enemy_manager.enemy_unregistered.connect(_on_enemy_unregistered)

	Events.PlayerBattleEnd.connect(_on_player_battle_end.unbind(1))
	Events.EnemyBattleEnd.connect(_on_enemy_battle_end.unbind(1))
	Events.effect_applied.connect(display_active_effects)
	Events.effect_display.connect(DamageNumbers.display_effect)


func _setup_effect_cycle_timer() -> void:
	_effect_cycle_timer = Timer.new()
	_effect_cycle_timer.wait_time = EFFECT_DISPLAY_DURATION
	_effect_cycle_timer.autostart = true
	_effect_cycle_timer.timeout.connect(_on_effect_cycle_tick)
	add_child(_effect_cycle_timer)


func _connect_player_icon_hover_signal() -> void:
	var player_icon = player_view.player_bars_container.statuseffecticon
	player_icon.mouse_entered.connect(func(): _is_player_icon_hovered = true; _check_pause_timer())
	player_icon.mouse_exited.connect(func(): _is_player_icon_hovered = false; _check_pause_timer())


func _on_enemy_registered(view: EnemyView, stat_manager: Stat_Manager) -> void:
	if _enemy_entries.has(stat_manager):
		return
	_enemy_entries[stat_manager] = {"view": view, "index": 0, "hovered": false}
	_enemy_order.append(stat_manager)

	var icon = view.enemy_bars_container.statuseffecticon
	icon.mouse_entered.connect(_on_enemy_icon_hover.bind(stat_manager, true))
	icon.mouse_exited.connect(_on_enemy_icon_hover.bind(stat_manager, false))


func _on_enemy_unregistered(view: EnemyView) -> void:
	var stat_manager: Stat_Manager = enemy_manager.get_stat_manager_for(view)
	if stat_manager and _enemy_entries.has(stat_manager):
		_enemy_entries.erase(stat_manager)
		_enemy_order.erase(stat_manager)


func _on_enemy_icon_hover(stat_manager: Stat_Manager, hovered: bool) -> void:
	if _enemy_entries.has(stat_manager):
		_enemy_entries[stat_manager]["hovered"] = hovered
	_check_pause_timer()


func _check_pause_timer() -> void:
	var any_enemy_hovered := false
	for entry in _enemy_entries.values():
		if entry["hovered"]:
			any_enemy_hovered = true
			break
	_effect_cycle_timer.paused = _is_player_icon_hovered or any_enemy_hovered


func _on_effect_cycle_tick() -> void:
	_advance_player_effect()
	for stat_manager in _enemy_order:
		_advance_enemy_effect(stat_manager)


func _advance_player_effect() -> void:
	var effects = player_stat_manager.Player.ActiveEffects.filter(func(e): return e != null)
	if effects.is_empty():
		player_view.player_bars_container.statuseffecticon.texture = null
		player_view.player_bars_container.turns_remaining.text = ""
		return
	if effects.size() == 1:
		player_view.player_bars_container.statuseffecticon.texture = effects[0].status_icon
		player_view.player_bars_container.turns_remaining.text = str(effects[0].current_duration)
		return
	_player_effect_index = _player_effect_index % effects.size()
	var effect = effects[_player_effect_index]
	_tween_icon_swap(
		player_view.player_bars_container.statuseffecticon,
		player_view.player_bars_container.turns_remaining,
		effect
	)
	_player_effect_index = (_player_effect_index + 1) % effects.size()


func _advance_enemy_effect(stat_manager: Stat_Manager) -> void:
	var entry: Dictionary = _enemy_entries.get(stat_manager)
	if not entry:
		return
	var view: EnemyView = entry["view"]
	var effects = stat_manager.Entity.ActiveEffects.filter(func(e): return e != null)

	if effects.is_empty():
		view.enemy_bars_container.statuseffecticon.texture = null
		view.enemy_bars_container.turns_remaining.text = ""
		return
	if effects.size() == 1:
		view.enemy_bars_container.statuseffecticon.texture = effects[0].status_icon
		view.enemy_bars_container.turns_remaining.text = str(effects[0].current_duration)
		return

	entry["index"] = entry["index"] % effects.size()
	var effect = effects[entry["index"]]
	_tween_icon_swap(
		view.enemy_bars_container.statuseffecticon,
		view.enemy_bars_container.turns_remaining,
		effect
	)
	entry["index"] = (entry["index"] + 1) % effects.size()


func _tween_icon_swap(icon: TextureRect, label: Label, effect: Resource) -> void:
	var tween = create_tween()
	tween.set_parallel(false)

	tween.tween_property(icon, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func():
		icon.texture = effect.status_icon
		label.text = str(effect.current_duration)
	)
	tween.tween_property(icon, "modulate:a", 1.0, 0.15)


func display_active_effects() -> void:
	_player_effect_index = 0
	for stat_manager in _enemy_order:
		_enemy_entries[stat_manager]["index"] = 0
	_on_effect_cycle_tick()

########################################################################

func tick_effects(target: Stat_Manager) -> void:
	var target_array
	var target_stats
	if target.Entity is CharacterInstance:
		target_array = target.Player.ActiveEffects
		target_stats = target.Player
	elif target.Entity is EnemyBattlerStats:
		target_stats = target.Entity
		target_array = target.Entity.ActiveEffects
	else:
		return
	for i in range(target_array.size() - 1, -1, -1):
		if target_array[i] is StatusEffect:
			target_array[i].on_tick(target_stats)
	display_active_effects()


func _on_player_battle_end() -> void:
	tick_effects(player_stat_manager)
	phase_manager.advance_to_next_phase()


func _on_enemy_battle_end() -> void:
	await _tick_enemies_sequentially()
	phase_manager.advance_to_next_phase()


func _tick_enemies_sequentially() -> void:
	for stat_manager in _enemy_order:
		tick_effects(stat_manager)
		if stat_manager != _enemy_order.back():
			await get_tree().create_timer(ENEMY_TICK_DELAY, true, false, false).timeout
