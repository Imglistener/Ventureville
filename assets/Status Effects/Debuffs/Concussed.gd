class_name Concussed extends StatusEffect
var tree : SceneTree
func _init() -> void:
	status_icon = preload("res://assets/GUI/concussed.png")

func on_apply(targets: Array[Node], duration: int = 1) -> void:
	if targets[0]:
		tree = targets[0].get_tree()
	for target in targets:
		if not target:
			continue
		if target is EnemyView:
			var effects = target.Enemy.Entity.ActiveEffects
			var existing = find_same_effect(effects)
			var anchor = target.Enemy.Entity.damage_number_anchor
			if existing:
				existing.current_duration += duration
				if anchor:
					Events.effect_display.emit(self, anchor, anchor.global_position)
			else:
				var instance = self.duplicate()
				instance.tree = tree
				instance.current_duration = duration
				effects.append(instance)
				target.Enemy.EnemyThoughts.disable_attacks()
				if anchor:
					Events.effect_display.emit(self, anchor, anchor.global_position)

		elif target is Stat_Manager:
			var effects = target.Player.ActiveEffects
			var existing = find_same_effect(effects)
			var anchor: Node2D = target.Player.damage_number_anchor
			if existing:
				existing.current_duration += duration
				if anchor:
					Events.effect_display.emit(self, anchor, anchor.global_position)

			else:
				var instance = self.duplicate()
				instance.current_duration = duration
				instance.tree = tree
				effects.append(instance)
				if anchor:
					Events.effect_display.emit(self, anchor, anchor.global_position)

	Events.effect_applied.emit()

func is_applicable(targets: Array[Node]) -> bool:
	var target = targets[0]
	if target is Stat_Manager:
		return target.Player.current_health <= target.Player.Max_HP/2
	elif target is EnemyView:
		return target.Enemy.Entity.current_health <= target.Enemy.Entity.Max_HP/2
	else:
		return false

func on_tick(target: BaseBattlerStats) -> void:
	if target is CharacterInstance:
		current_duration -= 1
		if current_duration <= 0:
			on_remove(target)
	elif target is EnemyBattlerStats:
		current_duration -= 1
	if current_duration <= 0:
		on_remove(target)
