extends EnemyAction

@export var Phases: Array[PhaseData] = []
@onready var Queen: EnemyAction = $"../AttackAction3"
@onready var King: EnemyAction = $"../AttackAction2"
@onready var Stare: EnemyAction = $"../AttackAction"

var phase_index := 0
var thresholds: Array[float] = []
var SoundBus: AudioStreamPlayer

func _ready() -> void:
	SoundBus = get_tree().get_first_node_in_group("SFXBus")

# Divides Max_HP into equal segments, one threshold per phase.
# e.g. 3 phases on 1000 HP -> triggers at 750, 500, 250
func _build_thresholds() -> void:
	var max_hp := Enemy.Enemy.Entity.Max_HP
	var count := Phases.size()
	thresholds.clear()
	for i in count:
		thresholds.append(max_hp * (1.0 - float(i + 1) / float(count + 1)))

func is_usable() -> bool:
	if not Enemy or Phases.is_empty() or phase_index >= Phases.size():
		return false
	if thresholds.is_empty():
		_build_thresholds()
	return Enemy.Enemy.Entity.current_health <= thresholds[phase_index]

func use_action() -> void:
	if not Enemy or not target or phase_index >= Phases.size():
		return
	super()

	var phase := Phases[phase_index]
	phase_index += 1
	if phase_index == 1:
		King.ActionChance = 8
		Queen.ActionChance = 2
	if phase_index == 2:
		King.ActionChance = 2
		Queen.ActionChance = 10
		Stare.ActionChance = 0
	
	

	var entity := Enemy.Enemy.Entity
	var original_scale := Enemy.scale
	SoundBus.play_sfx(SoundEffect)

	var beat1 := create_tween().set_trans(Tween.TRANS_EXPO).set_parallel(true)
	beat1.tween_property(Enemy, "scale", original_scale * Vector2(1.35, 0.72), 0.07)
	beat1.tween_property(Enemy, "modulate", Color.WHITE * 3.5, 0.07)
	await beat1.finished

	var recoil1 := create_tween().set_trans(Tween.TRANS_EXPO).set_parallel(true)
	recoil1.tween_property(Enemy, "scale", original_scale * Vector2(0.88, 1.12), 0.09)
	recoil1.tween_property(Enemy, "modulate", Color.WHITE * 0.6, 0.09)
	await recoil1.finished

	var beat2 := create_tween().set_trans(Tween.TRANS_EXPO).set_parallel(true)
	beat2.tween_property(Enemy, "scale", original_scale * Vector2(1.6, 0.55), 0.06)
	beat2.tween_property(Enemy, "modulate", Color.WHITE * 5.0, 0.06)
	await beat2.finished

	entity.Battler_Art_Normal = phase.Normal
	entity.Battler_Art_Hovered = phase.Hover
	entity.DamageBonus += phase.DamageBonus
	Enemy.update_enemy_view(phase.Normal, phase.Hover)
	Enemy.Enemy.phase_transition()
	entity.heal(entity.Max_HP)

	var settle := create_tween().set_parallel(true)
	settle.tween_property(Enemy, "scale", original_scale * 1.1, 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	settle.tween_property(Enemy, "modulate", Color.WHITE, 0.25) \
		.set_trans(Tween.TRANS_QUINT)
	await settle.finished

	var snap := create_tween()
	snap.tween_property(Enemy, "scale", original_scale, 0.18) \
		.set_trans(Tween.TRANS_SINE)
	await snap.finished

	Events.EnemyActionCompleted.emit(self)
