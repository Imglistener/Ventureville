class_name DamageUP extends StatusEffect
var tree
var applied_to: BaseBattlerStats
var amount: int
func _init() -> void:
	status_icon = preload("res://assets/GUI/AttackUP.png")
func on_apply(targets: Array[Node], duration : int = 1) -> void:
	if targets[0]:
		tree = targets[0].get_tree()
	for target in targets:
		if not target:
			continue
		var Enemy = target.get_tree().get_first_node_in_group('Enemies') as EnemyView
		var Player = target.get_tree().get_first_node_in_group('player').player_view as PlayerView
		if target is Stat_Manager:
			var effects = target.Player.ActiveEffects
			var existing = find_same_effect(effects)
			if existing:
				if existing.current_duration < duration:
					existing.current_duration = duration
				applied_to = target.Player
				Events.effect_applied.emit()
				Events.effect_display.emit(self, false, Enemy.position)
			else:
				var instance = self.duplicate()
				instance.tree = tree
				instance.current_duration = duration
				effects.append(instance)
				instance.applied_to = target.Player
				instance.amount = amount
				instance.on_activate()
				Events.effect_applied.emit()
				Events.effect_display.emit(self, false, Enemy.position)
		if target is EnemyView:
			var effects = target.Enemy.Entity.ActiveEffects
			var existing = find_same_effect(effects)
			if existing:
				if existing.current_duration < duration:
					existing.current_duration = duration
				applied_to = target.Enemy.Entity
				Events.effect_applied.emit()
				Events.effect_display.emit(self, true, Player.position)
			else:
				var instance = self.duplicate()
				instance.tree = tree
				instance.current_duration = duration
				effects.append(instance)
				instance.applied_to = target.Enemy.Entity
				instance.amount = amount
				instance.on_activate()
				Events.effect_applied.emit()
				Events.effect_display.emit(self, true, Player.position)

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
