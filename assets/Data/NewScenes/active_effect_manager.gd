class_name ActiveEffectManager extends Node

@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var enemy_stat_manager: Stat_Manager = $"../EnemyStatManager"
@onready var enemy: EnemyView = $"../../Control_Layer/Enemy"
@onready var player_view: PlayerView = $"../../Control_Layer/Control_Base/Base_Margin/MarginContainer/PlayerView"
@onready var phase_manager: PhaseManager = $"../PhaseManager"


# Add these variables at the top of your class
var _effect_cycle_timer: Timer
var _player_effect_index: int = 0
var _enemy_effect_index: int = 0
var _is_player_icon_hovered: bool = false
var _is_enemy_icon_hovered: bool = false
const EFFECT_DISPLAY_DURATION: float = 2.0

func _ready() -> void:
	_setup_effect_cycle_timer()
	_connect_icon_hover_signals()
	Events.PlayerBattleEnd.connect(tick_effects.bind(player_stat_manager).unbind(1))
	Events.EnemyBattleEnd.connect(tick_effects.bind(enemy_stat_manager).unbind(1))
func _setup_effect_cycle_timer() -> void:
	_effect_cycle_timer = Timer.new()
	_effect_cycle_timer.wait_time = EFFECT_DISPLAY_DURATION
	_effect_cycle_timer.autostart = true
	_effect_cycle_timer.timeout.connect(_on_effect_cycle_tick)
	add_child(_effect_cycle_timer)

func _connect_icon_hover_signals() -> void:
	var player_icon = player_view.player_bars_container.statuseffecticon
	var enemy_icon = enemy.enemy_bars_container.statuseffecticon

	player_icon.mouse_entered.connect(func(): _is_player_icon_hovered = true; _check_pause_timer())
	player_icon.mouse_exited.connect(func(): _is_player_icon_hovered = false; _check_pause_timer())
	enemy_icon.mouse_entered.connect(func(): _is_enemy_icon_hovered = true; _check_pause_timer())
	enemy_icon.mouse_exited.connect(func(): _is_enemy_icon_hovered = false; _check_pause_timer())

func _check_pause_timer() -> void:
	if _is_player_icon_hovered or _is_enemy_icon_hovered:
		_effect_cycle_timer.paused = true
	else:
		_effect_cycle_timer.paused = false

func _on_effect_cycle_tick() -> void:
	_advance_player_effect()
	_advance_enemy_effect()

func _advance_player_effect() -> void:
	var effects = player_stat_manager.Player.ActiveEffects.filter(func(e): return e != null)
	if effects.is_empty():
		player_view.player_bars_container.statuseffecticon.texture = null
		player_view.player_bars_container.turns_remaining.text = ""
		return

	_player_effect_index = _player_effect_index % effects.size()
	var effect = effects[_player_effect_index]
	_tween_icon_swap(
		player_view.player_bars_container.statuseffecticon,
		player_view.player_bars_container.turns_remaining,
		effect
	)
	_player_effect_index = (_player_effect_index + 1) % effects.size()

func _advance_enemy_effect() -> void:
	var effects = enemy_stat_manager.Entity.ActiveEffects.filter(func(e): return e != null)
	if effects.is_empty():
		enemy.enemy_bars_container.statuseffecticon.texture = null
		enemy.enemy_bars_container.turns_remaining.text = ""
		return

	_enemy_effect_index = _enemy_effect_index % effects.size()
	var effect = effects[_enemy_effect_index]
	_tween_icon_swap(
		enemy.enemy_bars_container.statuseffecticon,
		enemy.enemy_bars_container.turns_remaining,
		effect
	)
	_enemy_effect_index = (_enemy_effect_index + 1) % effects.size()

func _tween_icon_swap(icon: TextureRect, label: Label, effect: Resource) -> void:
	var tween = create_tween()
	tween.set_parallel(false)

	# Fade out
	tween.tween_property(icon, "modulate:a", 0.0, 0.15)

	# Swap content mid-fade (via callable)
	tween.tween_callback(func():
		icon.texture = effect.status_icon
		label.text = str(effect.current_duration)
	)

	# Fade in
	tween.tween_property(icon, "modulate:a", 1.0, 0.15)

# Call this when you need to force a UI refresh (e.g. after effects are added/removed)
func display_active_effects() -> void:
	_player_effect_index = 0
	_enemy_effect_index = 0
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
	else: return
	for i in range(target_array.size() - 1, -1, -1 ):
		if target_array[i] is StatusEffect:
			target_array[i].on_tick(target_stats)
	display_active_effects()
	phase_manager.advance_to_next_phase()
