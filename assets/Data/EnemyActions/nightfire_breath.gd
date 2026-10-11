extends EnemyAction
## Gladius exhales Nightfire: applies Burning to the player.
## Conditional action with a cooldown. Usable once every `cooldown_turns` turns.

@export var burn: StatusEffect          # assign Burning.tres in the editor
@export var burn_stacks: int = 5
@export var cooldown_turns: int = 5

var SFXBus: AudioStreamPlayer
var _last_used_turn: int = 0

@onready var phase_manager: PhaseManager = $"../../../PhaseManager"


func _ready() -> void:
	SFXBus = get_tree().get_first_node_in_group("SFXBus")
	# Starts on cooldown, so the first breath comes `cooldown_turns` turns into the fight.
	_last_used_turn = phase_manager.turn_counter


# Must be idempotent: EnemyAI/Stat_Manager call this more than once per standby.
func is_usable() -> bool:
	if not Enemy or not burn:
		return false
	return phase_manager.turn_counter - _last_used_turn >= cooldown_turns


func use_action() -> void:
	if not Enemy or not target:
		return
	super()
	_last_used_turn = phase_manager.turn_counter
	if SoundEffect:
		SFXBus.play_sfx(SoundEffect)

	var player_targets: Array[Node] = [target]
	var view := Enemy.enemy_view
	var original_scale := view.scale
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	tween.tween_property(view, "scale", original_scale * 1.3, 0.4)
	tween.parallel().tween_property(view, "modulate", Color(2.0, 0.8, 0.3), 0.4)
	tween.tween_callback(func():
		burn.on_apply(player_targets, burn_stacks)
		Events.effect_applied.emit()   # Burning.on_apply doesn't refresh the status icon itself
	)
	tween.tween_interval(0.25)
	tween.tween_property(view, "scale", original_scale, 0.3)
	tween.parallel().tween_property(view, "modulate", Color.WHITE, 0.3)
	tween.finished.connect(func(): Events.EnemyActionCompleted.emit(self));
