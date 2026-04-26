extends Card

@export var BaseDamage: int

func apply_effect(targets : Array[Node]) -> void:
	var damage_effect := AttackEffect.new()
	damage_effect.amount = BaseDamage
	damage_effect.activate(targets)
