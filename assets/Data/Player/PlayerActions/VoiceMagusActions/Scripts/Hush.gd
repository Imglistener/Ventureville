extends DebuffCard
## Concussed on the target: it cannot use Attack actions for its next turn.
## (Defend / Buff / Debuff moves still happen.)

@export var concussed: Concussed
@export var duration: int = 1


func _execute(_player: Stat_Manager, targets: Array[Node]) -> void:
	if not concussed:
		return
	var enemies: Array[Node] = []
	for t in targets:
		if t is EnemyView:
			enemies.append(t)
	if enemies.is_empty():
		return
	_apply_status(concussed, enemies, duration)
