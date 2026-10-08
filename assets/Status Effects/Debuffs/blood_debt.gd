class_name BloodDebt extends StatusEffect
## Blood Debt: no duration. `current_duration` is the debt amount (multiples of 10).
## End of turn: take that much true damage, then the debt drops by 10.
## Healing also reduces the debt by 10 per heal.

const DEBT_STEP := 10

func _init() -> void:
	status_icon = preload("res://assets/GUI/Bleeding_Icon.png")

func on_apply(targets: Array[Node], duration: int = DEBT_STEP) -> void:
	var amount := _snap_up(duration)
	if amount <= 0:
		return

	for target in targets:
		if not target:
			continue

		var effects: Array
		var anchor: Node2D
		if target is EnemyView:
			effects = target.Enemy.Entity.ActiveEffects
			anchor = target.Enemy.enemy.effect_vfx_marker
		elif target is Stat_Manager:
			effects = target.Player.ActiveEffects
			anchor = target.player_view.effect_guide
		else:
			continue

		var existing = find_same_effect(effects)
		if existing:
			existing.current_duration += amount
		else:
			var instance = self.duplicate()
			instance.current_duration = amount
			effects.append(instance)

		if anchor:
			Events.effect_display.emit(self, anchor, anchor.global_position)

	Events.effect_applied.emit()

func is_applicable(_targets: Array[Node]) -> bool:
	return true

func on_tick(target: BaseBattlerStats) -> void:
	if current_duration <= 0:
		on_remove(target)
		return

	var damage := current_duration
	target.true_take_damage(damage)
	if target.damage_number_anchor:
		DamageNumbers.display_number(damage, target.damage_number_anchor, target.damage_numbers)

	current_duration = maxi(current_duration - DEBT_STEP, 0)

func on_heal(target: BaseBattlerStats) -> void:
	current_duration = maxi(current_duration - DEBT_STEP, 0)
	if current_duration <= 0:
		on_remove(target)
	Events.effect_applied.emit()   # refreshes the icon / number

func _snap_up(value: int) -> int:
	return ceili(value / float(DEBT_STEP)) * DEBT_STEP
