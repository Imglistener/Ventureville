extends AttackCard

@export var VFX: PackedScene


func  _calculate_total(character: CharacterInstance) -> int:
	if not character:
		return 0
	var bonus := 0
	var index := character.stats.find(StatsScaled)
	if index != -1:
		bonus = character.stats[index].stat_scaling_value
	return int(((base_damage + bonus)/4) * character.get_attack_bonus())

func _execute(_player: Stat_Manager, targets: Array[Node]) -> void:
	_deal_damage(targets, _calculate_total(_player.Player))
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
