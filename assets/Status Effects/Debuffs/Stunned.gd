class_name Stunned extends StatusEffect
## Enemy: skips its next turn. Player: all cards disabled and AP drained for a turn.
## The skip/disable logic lives where turns and cards are handled; this is just the marker.

func _init() -> void:
	status_name = StatusEffects.Stunned
	default_duration = 1
	status_icon = preload("res://assets/GUI/horrified.png")   # placeholder art
	effect_texture = status_icon
	status_description = "The Affected Entity loses its next turn."


func on_apply(targets: Array[Node], duration: int = 1) -> void:
	for target in targets:
		var entity := _get_entity(target) if target else null
		if not entity:
			continue
		var existing := find_same_effect(entity.ActiveEffects)
		if existing:
			existing.current_duration = maxi(existing.current_duration, duration)   # never stacks
		else:
			var instance := self.duplicate() as Stunned
			instance.current_duration = duration
			entity.ActiveEffects.append(instance)
		var anchor := _get_anchor(target)
		if anchor:
			Events.effect_display.emit(self, anchor, anchor.global_position)
	Events.effect_applied.emit()


func on_tick(target: BaseBattlerStats) -> void:
	current_duration -= 1
	if current_duration <= 0:
		on_remove(target)
