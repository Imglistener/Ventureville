extends EnemyAction
## Gladius' finisher. Only available in Phase 2, once he is back down to
## `hp_threshold` of his Max HP. One heavy Fire hit, then Burning.
## Conditional action, used once.

@export var Damage: int = 50
@export var damagetype: DamageType        # Fire.tres
@export var burn: StatusEffect            # Burning.tres
@export var burn_stacks: int = 25
@export_range(0.05, 1.0) var hp_threshold: float = 0.5


var SFXBus: AudioStreamPlayer
var used := false


func _ready() -> void:
	SFXBus = get_tree().get_first_node_in_group("SFXBus")


# Must be idempotent: EnemyAI/Stat_Manager call this more than once per standby.
func is_usable() -> bool:
	if used or not Enemy or not burn:
		return false
	var entity := Enemy.Enemy.Entity
	if entity.is_stunned() or entity.get_status(Concussed):
		return false
	return entity.get_status(Charging) != null


func use_action() -> void:
	if not Enemy or not target:
		return
	super()
	used = true
	var entity := Enemy.Enemy.Entity
	var charge := entity.get_status(Charging)
	if charge:
		charge.on_remove(entity) 

	var damage_effect := AttackEffect.new()
	damage_effect.damage_type = damagetype
	damage_effect.source = entity
	damage_effect.amount = int(((Damage * entity.DamageBonus) / 2) * entity.get_attack_bonus())

	var target_array: Array[Node] = [target]
	if SoundEffect:
		SFXBus.play_sfx(SoundEffect)

	var view := Enemy.enemy_view
	var original_scale := view.scale
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	# Wind-up: swell and glow
	tween.tween_property(view, "scale", original_scale * 1.6, 0.6)
	tween.parallel().tween_property(view, "modulate", Color(3.0, 1.0, 0.3), 0.6)
	# Detonation
	tween.tween_callback(_detonate.bind(damage_effect, target_array))
	tween.tween_interval(0.35)
	tween.tween_property(view, "scale", original_scale, 0.4)
	tween.parallel().tween_property(view, "modulate", Color.WHITE, 0.4)

	tween.finished.connect(func(): Events.EnemyActionCompleted.emit(self))


func _detonate(damage_effect: AttackEffect, target_array: Array[Node]) -> void:
	damage_effect.activate(target_array)
	# Burning is applied whether or not the hit was blocked.
	if target.Player.current_health > 0:
		burn.on_apply(target_array, burn_stacks)
		Events.effect_applied.emit()   # Burning.on_apply doesn't refresh the status icon itself
