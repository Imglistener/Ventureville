class_name Burning extends StatusEffect

func on_apply(targets: Array[Node], duration: int = 1) -> void:
	for target in targets:
		if not target:
			continue
		if target is EnemyView:
			var effects = target.Enemy.Entity.ActiveEffects
			var existing = find_same_effect(effects)
			if existing:
				existing.current_duration += duration
			else:
				var instance = self.duplicate()
				instance.current_duration = duration
				effects.append(instance)

		elif target is Stat_Manager:
			var effects = target.Player.ActiveEffects
			var existing = find_same_effect(effects)
			if existing:
				existing.current_duration += duration
			else:
				var instance = self.duplicate()
				instance.current_duration = duration
				effects.append(instance)

func on_tick(target: BaseBattlerStats) -> void:
	var effect = find_same_effect(target.ActiveEffects)
	var damage : int = effect.current_duration
	target.take_damage(damage, null)
	effect.current_duration -= 1
	



func on_remove(target: BaseBattlerStats) -> void:
	var existing = find_same_effect(target.ActiveEffects)
	if existing:
		target.ActiveEffects.erase(existing)
