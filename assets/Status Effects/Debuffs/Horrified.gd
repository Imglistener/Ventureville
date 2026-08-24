class_name Horrified extends StatusEffect
var tree : SceneTree
func _init() -> void:
	status_icon = preload("res://assets/GUI/horrified.png")

func on_apply(targets: Array[Node], duration: int = 1) -> void:
	if targets[0]:
		tree = targets[0].get_tree()
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
				instance.tree = tree
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
				instance.tree = tree
				effects.append(instance)
	Events.effect_applied.emit()

func is_applicable(targets: Array[Node]) -> bool:
	var target = targets[0]
	if target is Stat_Manager:
		return target.Player.current_sanity <= target.Player.Max_SAN/2
	elif target is EnemyView:
		return target.Enemy.Entity.current_sanity <= target.Enemy.Entity.Max_SAN/2
	else:
		return false

func on_tick(target: BaseBattlerStats) -> void:
	if target is CharacterInstance:
		var horror_lvl: int = randi_range(0, 3)
		if target.current_san_block > 0:
			current_duration -= 1
			if current_duration <= 0:
				on_remove(target)
			return
		else:
			target.AP -= horror_lvl
			current_duration -= 1
			if current_duration <= 0:
				on_remove(target)
	elif target is EnemyBattlerStats:
		var damage := 2 * current_duration
		if target.current_block > 0:
			target.take_damage(0, null)
			current_duration -= 1
			return
		target.take_damage(damage, null)
		if tree:
			var user = tree.get_first_node_in_group("player")
			user.Player.heal(damage)
		current_duration -= 1

	if current_duration <= 0:
		on_remove(target)
