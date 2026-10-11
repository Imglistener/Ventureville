extends EnemyAction
## Phase 2, at/below hp_threshold: Gladius spends a turn charging Nightfire Supernova.

@export var stun_threshold: int = 60
@export_range(0.05, 1.0) var hp_threshold: float = 0.55

@onready var phase_2_transition: EnemyAction = $"../Phase2Transition"
@onready var supernova: EnemyAction = $"../NightfireSupernova"

var SFXBus: AudioStreamPlayer


func _ready() -> void:
	SFXBus = get_tree().get_first_node_in_group("SFXBus")


# Idempotent.
func is_usable() -> bool:
	if not Enemy or supernova.used or not phase_2_transition.used:
		return false
	var entity := Enemy.Enemy.Entity
	if entity.is_stunned() or entity.get_status(Charging):
		return false
	return entity.current_health <= entity.Max_HP * hp_threshold



func use_action() -> void:
	if not Enemy or not target:
		return
	super()
	if SoundEffect:
		SFXBus.play_sfx(SoundEffect)

	var charging := Charging.new()
	charging.stun_threshold = stun_threshold
	var self_targets: Array[Node] = [Enemy]
	Enemy.Enemy.Entity.cleanse_status([BloodSyphon.new(), Concussed.new(), Burning.new(), DamageDown.new()])
	var view := Enemy.enemy_view
	var original_scale := view.scale
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	tween.tween_property(view, "scale", original_scale * 1.2, 0.5)
	tween.parallel().tween_property(view, "modulate", Color(2.5, 0.9, 0.3), 0.5)
	tween.tween_callback(charging.on_apply.bind(self_targets, 1))
	tween.tween_property(view, "scale", original_scale, 0.3)
	tween.parallel().tween_property(view, "modulate", Color.WHITE, 0.3)
	tween.finished.connect(func(): Events.EnemyActionCompleted.emit(self));
