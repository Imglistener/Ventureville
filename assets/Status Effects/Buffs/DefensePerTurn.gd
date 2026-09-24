class_name DefensePerTurn
extends StatusEffect

@export var amount_gained: int = 3
@export var use_duration:= false
var applied_entity : Stat_Manager

func set_duration(amount: int) -> void:
	current_duration = amount

func on_apply(targets: Array[Node], duration : int = 1) -> void:
	for target in targets:
		if not target:
			continue
		var effects := _get_effects_array(target)
		if effects == null:
			continue
		var existing = find_same_effect(effects)
		var anchor: Node2D = target.player_view.effect_guide
		if existing:
			existing.current_duration += duration
			Events.effect_display.emit(self, anchor, anchor.global_position)
		else:
			var instance = self.duplicate()
			instance.current_duration = duration
			instance.applied_entity = target
			effects.append(instance)
			if anchor:
				Events.effect_display.emit(self, anchor, anchor.global_position)

	Events.effect_applied.emit()

func on_tick(target: BaseBattlerStats) -> void:
	var block_effect := BlockEffect.new()
	block_effect.amount = current_duration if use_duration else amount_gained
	if not applied_entity:
		on_remove(target)
		return
	block_effect.activate([applied_entity])
	current_duration -= 1
	if current_duration <= 0:
		on_remove(target)


func _get_effects_array(target: Node) -> Array:
	if target is EnemyView:
		return target.Enemy.Entity.ActiveEffects
	elif target is Stat_Manager:
		return target.Player.ActiveEffects
	return []
