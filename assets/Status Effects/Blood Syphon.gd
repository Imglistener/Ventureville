class_name BloodSyphon extends StatusEffect

var tree : SceneTree

func on_apply(targets: Array[Node]) -> void:
	if targets[0]:
		tree = targets[0].get_tree()
	for target in targets:
		if not target:
			continue
		if target is EnemyView:
			var effects = target.Enemy.Entity.ActiveEffects
			var existing = _find_same_effect(effects)
			if existing:
				existing.current_duration += 1
			else:
				var instance = self.duplicate()
				instance.tree = tree
				instance.current_duration = 1
				effects.append(instance)

		elif target is Stat_Manager:
			var effects = target.Player.ActiveEffects
			var existing = _find_same_effect(effects)
			if existing:
				existing.current_duration += 1
			else:
				var instance = self.duplicate()
				instance.current_duration = 1
				instance.tree = tree
				effects.append(instance)


func _find_same_effect(effects: Array) -> StatusEffect:
	for effect in effects:
		if effect.get_script() == self.get_script():
			return effect
	return null

func on_tick(target: BaseBattlerStats) -> void:
	if target is CharacterInstance:
		var damage := 2 * current_duration
		target.take_damage(damage, null)
		if tree:
			var user = tree.get_first_node_in_group("Enemies")
			user.Enemy.Entity.heal(damage)
		current_duration -= 1
	if target is EnemyBattlerStats:
		var damage := 2 * current_duration
		target.take_damage(damage, null)
		if tree:
			var user = tree.get_first_node_in_group("player")
			user.Player.heal(damage)
		current_duration -= 1
	if current_duration == 0:
		on_remove(target)

func blood_syphon(user : BaseBattlerStats) -> void:
		user.heal(2 * current_duration)

func on_remove(target: BaseBattlerStats) -> void:
	var existing = _find_same_effect(target.ActiveEffects)
	if existing:
		target.ActiveEffects.erase(existing)
