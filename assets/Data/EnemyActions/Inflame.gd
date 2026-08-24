extends EnemyAction
@export var DamageBonus := 10
@export var Phase_2_Normal: Texture
@export var Phase_2_Hover: Texture
@export var threshold := 0
var exhausted := false
var SoundBus: AudioStreamPlayer

func _ready() -> void:
	SoundBus = get_tree().get_first_node_in_group("SFXBus")

func is_usable() -> bool:
	if not Enemy or exhausted:
		return false
	if threshold == 0 and Enemy.Enemy and Enemy.Enemy.Entity:
		threshold = Enemy.Enemy.Entity.Max_HP / 2
	var transforming := Enemy.Enemy.Entity.current_health <= threshold
	exhausted = transforming
	return transforming

func use_action() -> void:
	if not Enemy or not target:
		return
	super()
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_parallel(false)
	var entity := Enemy.Enemy.Entity
	var original_scale := Enemy.scale
	SoundBus.play_sfx(SoundEffect)
	tween.tween_property(Enemy, "scale", original_scale * Vector2(0.6, 1.4), 0.2)
	tween.tween_property(Enemy, "scale", original_scale * Vector2(1.8, 0.5), 0.15) \
		.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(Enemy, "modulate", Color.WHITE * 4.0, 0.05)
	tween.tween_callback(func():
		entity.Battler_Art_Normal = Phase_2_Normal
		entity.Battler_Art_Hovered = Phase_2_Hover
		entity.DamageBonus += DamageBonus
		Enemy.update_enemy_view(Phase_2_Normal,Phase_2_Hover)
		target.phase_transition()
		entity.heal(entity.Max_HP)
		
	)
	tween.tween_property(Enemy, "modulate", Color.WHITE, 0.3)
	tween.tween_property(Enemy, "scale", original_scale * 1.15, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(Enemy, "scale", original_scale, 0.2)
	tween.finished.connect(func():
		Events.EnemyActionCompleted.emit(self)
	)
