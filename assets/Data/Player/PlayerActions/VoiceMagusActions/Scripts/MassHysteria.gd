extends DebuffCard
## Rolls the Horrified effect table right now on every Horrified enemy. Stacks stay.
## target = ALLENEMIES.

func _execute(_player: Stat_Manager, targets: Array[Node]) -> void:
	for t in targets:
		if t is EnemyView:
			var entity := _entity_of(t)
			var h := entity.get_status(Horrified) as Horrified if entity else null
			if h:
				h.roll_effect(entity)
