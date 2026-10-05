extends DebuffCard

@export var BloodSyphonEffect: BloodSyphon
@export var RegenEffect: Regeneration
@export var stacks: int = 5

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	_apply_to_enemies(BloodSyphonEffect, targets, stacks)
	_apply_to_self(RegenEffect, player, stacks)
