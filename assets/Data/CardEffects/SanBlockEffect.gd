class_name SanBlockEffect extends CardEffect

var amount = 0

func activate(targets : Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is EnemyView:
				target.Enemy.Entity.current_san_block += amount
		if target is Stat_Manager:
			target.Entity.current_san_block += amount
