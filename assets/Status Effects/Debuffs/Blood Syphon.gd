class_name BloodSyphon extends StatusEffect
var damage_type : DamageType = load("res://assets/Enemies/Data/Damage Types/Blood.tres")

var tree : SceneTree

func _init() -> void:
	status_icon = preload("res://assets/GUI/Bleeding_Icon.png")

func on_apply(targets: Array[Node], duration: int = 1) -> void:
	if targets[0]:
		tree = targets[0].get_tree()
	for target in targets:
		if not target:
			continue
			Events.effect_applied.emit()
		if target is EnemyView:
			var effects = target.Enemy.Entity.ActiveEffects
			var existing = find_same_effect(effects)
			if existing:
				existing.current_duration += duration
				Events.effect_display.emit(self, true, target.global_position)
			else:
				var instance = self.duplicate()
				instance.tree = tree
				instance.current_duration = duration
				effects.append(instance)
				Events.effect_display.emit(self, true, target.global_position)

		elif target is Stat_Manager:
			var effects = target.Player.ActiveEffects
			var existing = _find_same_effect(effects)
			if existing:
				existing.current_duration += duration
			else:
				var instance = self.duplicate()
				instance.current_duration = duration
				instance.tree = tree
				effects.append(instance)
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
	var existing = find_same_effect(target.ActiveEffects)
	if existing:
		target.ActiveEffects.erase(existing)
		
func _find_same_effect(effects: Array) -> StatusEffect:
	for effect in effects:
		if effect.get_script() == self.get_script():
			return effect
	return null
