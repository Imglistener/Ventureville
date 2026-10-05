extends AttackCard

@export var AppliedEffect: StatusEffect
@export var syphon_duration: int = 2

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)

	var target := targets[0] as EnemyView
	var was_alive := target and target.Enemy and target.Enemy.Entity and target.Enemy.Entity.current_health > 0

	_deal_damage(targets, _calculate_total(player.Player))
	_apply_status(AppliedEffect, targets, syphon_duration, true)

	if was_alive and target.Enemy.Entity.current_health <= 0:
		player.Player.heal(blood_tax)
