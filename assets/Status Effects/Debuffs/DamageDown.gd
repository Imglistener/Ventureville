class_name DamageDown extends StatusEffect

## Fraction of damage removed. 0.05 = 5% Damage Down.
var amount: float = 0.0


func on_apply(targets: Array[Node], duration: int = 1) -> void:
	for target in targets:
		if not target:
			continue
		var entity := _get_entity(target)
		if not entity:
			continue
		var existing := find_same_effect(entity.ActiveEffects) as DamageDown
		if existing:
			# Refresh rather than stack, so repeat casts can't zero an enemy out.
			existing.amount = maxf(existing.amount, amount)
			existing.current_duration = maxi(existing.current_duration, duration)
		else:
			var instance := self.duplicate() as DamageDown
			instance.current_duration = duration
			instance.amount = amount
			entity.ActiveEffects.append(instance)
		entity.Stats_Changed.emit()
		var anchor := _get_anchor(target)
		if anchor:
			Events.effect_display.emit(self, anchor, anchor.global_position)
	Events.effect_applied.emit()


func on_tick(target: BaseBattlerStats) -> void:
	current_duration -= 1
	if current_duration <= 0:
		on_remove(target)


func on_remove(target: BaseBattlerStats) -> void:
	super(target)
	target.Stats_Changed.emit()
