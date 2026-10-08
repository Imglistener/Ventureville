class_name SanguineShell extends StatusEffect

@export_range(0.0, 1.0) var damage_reduction: float = 0.25

## Player effects tick at the end of the player's own turn, which would remove a
## duration-1 shell before the enemies act. The player's copy skips its first tick.
var skip_next_tick := false


func on_apply(targets: Array[Node], duration: int = 1) -> void:
	for target in targets:
		if not target:
			continue
		var entity := _get_entity(target)
		if not entity:
			continue
		var existing := find_same_effect(entity.ActiveEffects) as SanguineShell
		if existing:
			existing.current_duration += duration
			existing.skip_next_tick = target is Stat_Manager
		else:
			var instance := self.duplicate() as SanguineShell
			instance.current_duration = duration
			instance.skip_next_tick = target is Stat_Manager
			entity.ActiveEffects.append(instance)
		var anchor := _get_anchor(target)
		if anchor:
			Events.effect_display.emit(self, anchor, anchor.global_position)
	Events.effect_applied.emit()


func on_tick(target: BaseBattlerStats) -> void:
	if skip_next_tick:
		skip_next_tick = false
		return
	current_duration -= 1
	if current_duration <= 0:
		on_remove(target)


## Called by AttackEffect. Reduces damage only if the attacker has Blood Syphon.
func reduce_damage(amount: int, attacker: BaseBattlerStats) -> int:
	if amount <= 0 or not attacker:
		return amount
	for effect in attacker.ActiveEffects:
		if effect is BloodSyphon:
			return roundi(amount * (1.0 - damage_reduction))
	return amount
