extends AttackCard

@export var hits_after_sacrifice: int = 2
@export var hit_delay: float = 0.2

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var tracking_manager = player.get_tree().get_first_node_in_group('TurnTrackingManager') as TurnTrackingManager
	var total := _calculate_total(player.Player)
	var hits := hits_after_sacrifice if tracking_manager.sacrificed_this_turn(player) else 1


	var hit_targets: Array[Node] = targets.duplicate()
	var target := hit_targets[0] as EnemyView

	for i in hits:
		if i > 0:
			await player.get_tree().create_timer(hit_delay).timeout
		# Don't hit a corpse (would re-fire the death log / signals).
		if not target or not target.Enemy or target.Enemy.Entity.current_health <= 0:
			break
		_deal_damage(hit_targets, total)
