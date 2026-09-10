class_name Regeneration extends StatusEffect

func _init() -> void:
	status_icon = preload("res://assets/GUI/regen_2_Icon.png")
func on_apply(targets: Array[Node], duration : int = 1) -> void:
	for target in targets:
		if not target:
			continue
		var effects := _get_effects_array(target)
		if effects == null:
			continue
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
	var heal_amount = 2 * effect.current_duration
	target.heal(heal_amount)
	effect.current_duration -= 1

func _find_same_effect(effects: Array) -> StatusEffect:
	for effect in effects:
		if effect.get_script() == self.get_script():
			return effect
	return null

func _get_effects_array(target: Node) -> Array:
	if target is EnemyView:
		return target.Enemy.Entity.ActiveEffects
	elif target is Stat_Manager:
		return target.Player.ActiveEffects
	return []
