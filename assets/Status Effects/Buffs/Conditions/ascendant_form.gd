class_name AscendantFormCondition
extends BattleCondition
## Passive condition on the player:
##  - double damage to Blood Syphoned targets   (modify_outgoing_damage)
##  - heals half of any Blood Damage dealt       (on_damage_dealt, new hook)
##  - applies Blood Syphon to all enemies at the end of each of the owner's turns (on_tick)

@export var blood_effect: StatusEffect          # BloodSyphon.tres
@export var syphon_per_turn: int = 2
@export var damage_multiplier: float = 2.0
@export_range(0.0, 1.0) var blood_lifesteal: float = 0.5


func activate(targets: Array[Node]) -> void:
	var player := targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	if not player or find_same_effect(player.Player.BattleConditions):
		return
	var instance := self.duplicate() as AscendantFormCondition
	player.Player.BattleConditions.append(instance)
	Events.BattleConditionActivated.emit(instance, player.Player)
	Events.effect_display.emit(self, player.Player.damage_number_anchor, player.Player.damage_number_anchor.global_position)


func on_tick(targets: Array[Node]) -> void:
	if not blood_effect:
		return
	for target in targets:
		if target is EnemyView:
			var enemy_target: Array[Node] = [target]
			blood_effect.on_apply(enemy_target, syphon_per_turn)


func modify_outgoing_damage(amount: int, defender: BaseBattlerStats) -> int:
	if defender and _has_syphon(defender):
		return roundi(amount * damage_multiplier)
	return amount


func on_damage_dealt(dealt: int, damage_type: DamageType, source: BaseBattlerStats, _defender: BaseBattlerStats) -> void:
	if dealt <= 0 or not source or not damage_type:
		return
	if damage_type.Damage_Type != DamageType.DAMAGETYPE.Blood:
		return
	source.heal(roundi(dealt * blood_lifesteal))


func _has_syphon(entity: BaseBattlerStats) -> bool:
	for effect in entity.ActiveEffects:
		if effect is BloodSyphon:
			return true
	return false
