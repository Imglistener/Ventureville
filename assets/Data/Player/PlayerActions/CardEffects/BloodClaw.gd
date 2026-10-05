extends AttackCard

@export var VFX: PackedScene




func _execute(_player: Stat_Manager, targets: Array[Node]) -> void:
	_deal_damage(targets, base_damage)
	_play_vfx_on(targets[0])

func _play_vfx_on(node: Node) -> void:
	if not VFX:
		return
	var visual := VFX.instantiate()
	node.add_child(visual)
	visual.animation_player.play("BloodClaw")
	visual.animation_player.animation_finished.connect(
		func(_anim_name: StringName) -> void: visual.queue_free()
	);
