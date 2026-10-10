class_name NightfireSavageryCondition
extends BattleCondition
## If the owner attacks a Burning entity, the attack deals double damage.

@export var damage_multiplier: float = 2.0


func activate(targets: Array[Node]) -> void:
	for target in targets:
		if target is not EnemyView:
			continue
		var entity: BaseBattlerStats = target.Enemy.Entity
		if find_same_effect(entity.BattleConditions):
			continue
		var instance := self.duplicate() as NightfireSavageryCondition
		entity.BattleConditions.append(instance)
		Events.BattleConditionActivated.emit(instance, entity)
		var anchor: Node2D = target.effect_vfx_marker
		if anchor:
			Events.effect_display.emit(self, anchor, anchor.global_position)


func modify_outgoing_damage(amount: int, defender: BaseBattlerStats) -> int:
	if defender and _is_burning(defender):
		return roundi(amount * damage_multiplier)
	return amount


func _is_burning(entity: BaseBattlerStats) -> bool:
	for effect in entity.ActiveEffects:
		if effect is Burning:
			return true
	return false
