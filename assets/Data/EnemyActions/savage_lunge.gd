extends EnemyAction
## Gladius lunges at the player for Fire damage.
## If any damage gets through the player's block, applies Concussed.

@export var Damage: int = 40
@export var damagetype: DamageType         # Fire.tres
@export var concussed: StatusEffect        # Concussed.tres
@export var concussed_duration: int = 2

var SFXBus: AudioStreamPlayer


func _ready() -> void:
	SFXBus = get_tree().get_first_node_in_group("SFXBus")


func use_action() -> void:
	if not Enemy or not target:
		return
	super()
	var entity := Enemy.Enemy.Entity
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var original_scale = Enemy.scale
	var enlarged_scale = original_scale * 1.5

	var damage_effect := AttackEffect.new()
	damage_effect.damage_type = damagetype
	damage_effect.source = entity
	damage_effect.amount = int(((Damage * entity.DamageBonus) / 2) * entity.get_attack_bonus())

	var target_array: Array[Node] = [target]
	if SoundEffect:
		SFXBus.play_sfx(SoundEffect)

	tween.tween_property(Enemy.enemy_view, "scale", enlarged_scale, 0.2)
	tween.tween_callback(_strike.bind(damage_effect, target_array))
	tween.tween_interval(0.25)
	tween.tween_property(Enemy.enemy_view, "scale", original_scale, 0.2)

	tween.finished.connect(
		func():
			Events.EnemyActionCompleted.emit(self)
	)


func _strike(damage_effect: AttackEffect, target_array: Array[Node]) -> void:
	var player := target.Player
	var hp_before := player.current_health
	damage_effect.activate(target_array)

	# "Not blocked" = damage actually got through (block, resistance and
	# Sanguine Shell are all already accounted for in the real HP change).
	if player.current_health < hp_before and concussed:
		concussed.on_apply(target_array, concussed_duration)


func setup_from_data() -> void:
	super()
	Damage = Enemy_Data.Damage
	damagetype = Enemy_Data.DamageElement
