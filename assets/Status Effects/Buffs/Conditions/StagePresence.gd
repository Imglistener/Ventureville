class_name StagePresenceCondition
extends VoiceCondition
## Your Psychic damage is +25% against Horrified targets. The SAN half scales with it,
## because it is computed from the final hit.

@export var multiplier: float = 1.25


func modify_typed_damage(amount: int, defender: BaseBattlerStats, damage_type: DamageType) -> int:
	if damage_type and damage_type.Damage_Type == DamageType.DAMAGETYPE.Psychic \
			and defender and defender.get_status(Horrified):
		return roundi(amount * multiplier)
	return amount
