extends EnemyAction

@export var Damage : int = 10
@export var damagetype: DamageType


var SFXBus : AudioStreamPlayer

func _ready() -> void:
	SFXBus = get_tree().get_first_node_in_group("SFXBus")

func use_action() -> void:
	if not Enemy or not target:
		return
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var original_scale = Enemy.scale
	var enlarged_scale = original_scale * 1.5

	var damage_effect = AttackEffect.new()
	damage_effect.damage_type = damagetype
	var target_array: Array[Node] = [target]
	damage_effect.amount = Damage * Enemy.Enemy.Entity.DamageBonus
	SFXBus.stream = SoundEffect
	SFXBus.play()
	tween.tween_property(Enemy.enemy_view, "scale", enlarged_scale, 0.4)
	tween.tween_callback(damage_effect.activate.bind(target_array))
	tween.tween_interval(0.25)
	tween.tween_property(Enemy.enemy_view, "scale", original_scale, 0.4)

	tween.finished.connect(
		func():
			Events.EnemyActionCompleted.emit(Enemy)
	)
