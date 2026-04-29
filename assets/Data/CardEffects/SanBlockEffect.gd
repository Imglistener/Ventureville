class_name SanBlockEffect extends CardEffect

var amount = 0

func activate(targets : Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is EnemyView:
				target.Enemy.Entity.current_san_block += amount
				target.Enemy.Entity.san_block_gained.emit(amount, target.Enemy.Entity.entity_name)
		if target is Stat_Manager:
			target.Player.current_san_block += amount
			target.Player.san_block_gained.emit(amount, target.Player.entity_name)
