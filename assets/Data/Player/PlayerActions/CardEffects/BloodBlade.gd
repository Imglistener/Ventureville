extends AttackCard

@export var AppliedEffect: StatusEffect   # BloodSyphon.tres
@export var RegenEffect: StatusEffect     # Regeneration.tres

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	var total := _calculate_total(player.Player)
	_pay_blood_tax(player)
	_deal_damage(targets, total)

	var apply_count := randi_range(1, 3)
	for i in apply_count:
		_apply_status(AppliedEffect, targets, 1, true)   # skipped while the target has block
	_apply_to_self(RegenEffect, player, apply_count)
