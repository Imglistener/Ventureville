extends EnemyAction

@export var Damage : int = 10
@export var damagetype: DamageType
@export var number_hits: int

var SFXBus : AudioStreamPlayer

func _ready() -> void:
	SFXBus = get_tree().get_first_node_in_group("SFXBus")


func use_action() -> void:
	if not Enemy or not target:
		return
	super()
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var original_scale = Enemy.scale
	var enlarged_scale = original_scale * 1.5
	var Hemmorphage := BloodSyphon.new()
	var damage_effect = AttackEffect.new()
	damage_effect.damage_type = damagetype
	var target_array: Array[Node] = [target]
	damage_effect.amount = Damage * Enemy.Enemy.Entity.DamageBonus/3
	if Hemmorphage.is_applicable(target_array):
		Hemmorphage.on_apply(target_array, 3)
	SFXBus.play_sfx(SoundEffect)
	tween.tween_property(Enemy.enemy_view, "scale", enlarged_scale, 0.2)
	tween.tween_callback(trigger_attack_effect.bind(damage_effect, target_array))
	tween.tween_interval(0.25)
	tween.tween_property(Enemy.enemy_view, "scale", original_scale, 0.2)

	tween.finished.connect(
		func():
			Events.EnemyActionCompleted.emit(self)
	)
func trigger_attack_effect(damage: AttackEffect, target_array: Array[Node]) -> void:
	for i in range(number_hits):
		damage.activate(target_array)
