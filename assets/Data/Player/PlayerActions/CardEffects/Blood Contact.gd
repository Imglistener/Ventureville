extends AttackCard

@export var set_hp: int = 20


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	player.Player.current_health = mini(set_hp, player.Player.Max_HP)

	for t in targets:
		var entity := _entity_of(t)
		if entity and entity.current_health > 0:
			for i in range(2):
				_trigger_blood_syphon(entity)
				await player.get_tree().create_timer(0.1).timeout
