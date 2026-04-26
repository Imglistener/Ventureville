extends Card

@export var BaseShield: int = 8

func apply_effect(targets : Array[Node]) -> void:
	var block_effect := BlockEffect.new()
	block_effect.amount = BaseShield
	block_effect.activate(targets)
