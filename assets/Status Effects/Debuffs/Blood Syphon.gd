class_name BloodSyphon extends StatusEffect
var damage_type : DamageType = load("res://assets/Enemies/Data/Damage Types/Blood.tres")

func _init() -> void:
	status_icon = preload("res://assets/GUI/Bleeding_Icon.png")

func on_apply(targets: Array[Node], duration: int = 1) -> void:
	for target in targets:
		if not target:
			continue

		if target is EnemyView:
			var effects = target.Enemy.Entity.ActiveEffects
			var existing = _find_same_effect(effects)
			var anchor: Node2D = target.Enemy.Entity.damage_number_anchor
			if existing:
				existing.current_duration += duration
			else:
				var instance = self.duplicate()
				instance.current_duration = duration
				effects.append(instance)
			if anchor:
				Events.effect_display.emit(self, anchor, anchor.global_position)

		elif target is Stat_Manager:
			var effects = target.Player.ActiveEffects
			var existing = _find_same_effect(effects)
			var anchor: Node2D = target.Player.damage_number_anchor
			if existing:
				existing.current_duration += duration
			else:
				var instance = self.duplicate()
				instance.current_duration = duration
				effects.append(instance)
			if anchor:
				Events.effect_display.emit(self, anchor, anchor.global_position)

	Events.effect_applied.emit()


func on_tick(target: BaseBattlerStats) -> void:
	var effect = _find_same_effect(target.ActiveEffects)
	var damage = 2 * effect.current_duration
	if target.current_block > 0:
		target.take_damage(0, null)
	else:
		target.take_damage(damage, damage_type)
	effect.current_duration -= 1

func is_applicable(targets: Array[Node]) -> bool:
	var target = targets[0]
	if target is Stat_Manager:
		return target.Player.current_block == 0
	elif target is EnemyView:
		return target.Enemy.Entity.current_block == 0
	else:
		return false

func on_remove(target: BaseBattlerStats) -> void:
	var existing = _find_same_effect(target.ActiveEffects)
	if existing:
		target.ActiveEffects.erase(existing)

func _find_same_effect(effects: Array) -> StatusEffect:
	for effect in effects:
		if effect.get_script() == self.get_script():
			return effect
	return null
