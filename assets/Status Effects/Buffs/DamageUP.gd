class_name DamageUP extends StatusEffect
var applied_to: BaseBattlerStats
var amount: int

func _init() -> void:
	status_icon = preload("res://assets/GUI/Attack_UP_icon.png")

func on_apply(targets: Array[Node], duration : int = 1) -> void:
	for target in targets:
		if not target:
			continue

		if target is Stat_Manager:
			var effects = target.Player.ActiveEffects
			var existing = find_same_effect(effects)
			var anchor: Node2D = target.Player.damage_number_anchor
			if existing:
				if existing.current_duration < duration:
					existing.current_duration = duration
				applied_to = target.Player
				Events.effect_applied.emit()
				if anchor:
					Events.effect_display.emit(self, anchor, anchor.global_position)
			else:
				var instance = self.duplicate()
				instance.current_duration = duration
				effects.append(instance)
				instance.applied_to = target.Player
				instance.amount = amount
				instance.on_activate()
				Events.effect_applied.emit()
				if anchor:
					Events.effect_display.emit(self, anchor, anchor.global_position)

		if target is EnemyView:
			var effects = target.Enemy.Entity.ActiveEffects
			var existing = find_same_effect(effects)
			var anchor: Node2D = target.Enemy.Entity.damage_number_anchor
			if existing:
				if existing.current_duration < duration:
					existing.current_duration = duration
				applied_to = target.Enemy.Entity
				Events.effect_applied.emit()
				if anchor:
					Events.effect_display.emit(self, anchor, anchor.global_position)
			else:
				var instance = self.duplicate()
				instance.current_duration = duration
				effects.append(instance)
				instance.applied_to = target.Enemy.Entity
				instance.amount = amount
				instance.on_activate()
				Events.effect_applied.emit()
				if anchor:
					Events.effect_display.emit(self, anchor, anchor.global_position)

func on_activate() -> void:
	applied_to.modify_buff_modifier(amount)

func  on_tick(target: BaseBattlerStats) -> void:
	current_duration -= 1
	if current_duration <= 0:
		on_remove(target)

func on_remove(target: BaseBattlerStats) -> void:
	var existing = find_same_effect(target.ActiveEffects)
	if target.buff_damage_modifier >= amount:
		target.modify_buff_modifier(target.buff_damage_modifier - amount)
	else :
		target.modify_buff_modifier(0)
	if existing:
		target.ActiveEffects.erase(existing)

	Events.effect_applied.emit()
