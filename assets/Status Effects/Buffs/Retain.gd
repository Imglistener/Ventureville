class_name RetainHand
extends StatusEffect

var applied_to: CardHand


func on_apply(targets: Array[Node], duration : int = 1) -> void:
	for target in targets:
		if not target:
			continue

		if target is Stat_Manager:
			var effects = target.Player.ActiveEffects
			var existing = find_same_effect(effects)
			var anchor: Node2D = target.player_view.effect_guide
			if existing:
				if existing.current_duration < duration:
					existing.current_duration = duration
				applied_to = anchor.get_tree().get_first_node_in_group('hand')
				Events.effect_applied.emit()
				if anchor:
					Events.effect_display.emit(self, anchor, anchor.global_position)
			else:
				var instance = self.duplicate()
				instance.current_duration = duration
				effects.append(instance)
				instance.applied_to = anchor.get_tree().get_first_node_in_group('hand')
				instance.on_activate()
				Events.effect_applied.emit()
				if anchor:
					Events.effect_display.emit(self, anchor, anchor.global_position)

func on_activate() -> void:
	if applied_to:
		applied_to.is_retaining_hand = true
	

func  on_tick(target: BaseBattlerStats) -> void:
	current_duration -= 1
	if current_duration <= 0:
		on_remove(target)

func on_remove(target: BaseBattlerStats) -> void:
	if applied_to:
		applied_to.is_retaining_hand = false
	
	super(target)
	
