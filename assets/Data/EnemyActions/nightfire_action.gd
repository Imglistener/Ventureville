extends EnemyAction

@export var condition: BattleCondition
@onready var phase_2_transition: EnemyAction = $"../Phase2Transition"

var SFXBus: AudioStreamPlayer
var used := false


func _ready() -> void:
	SFXBus = get_tree().get_first_node_in_group("SFXBus")


# Must be idempotent: EnemyAI/Stat_Manager call this more than once per standby.
func is_usable() -> bool:
	return not used and Enemy != null and condition != null and phase_2_transition.used


func use_action() -> void:
	if not Enemy or not target:
		return
	super()
	used = true
	if SoundEffect:
		SFXBus.play_sfx(SoundEffect)

	var self_targets: Array[Node] = [Enemy]
	var view := Enemy.enemy_view
	var original_scale := view.scale
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	tween.tween_property(view, "scale", original_scale * 1.15, 0.3)
	tween.parallel().tween_property(view, "modulate", Color(2.0, 0.8, 0.3), 0.3)
	tween.tween_callback(condition.activate.bind(self_targets))
	tween.tween_property(view, "scale", original_scale, 0.3)
	tween.parallel().tween_property(view, "modulate", Color.WHITE, 0.3)
	tween.finished.connect(func(): Events.EnemyActionCompleted.emit(self))
