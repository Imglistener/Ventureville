extends DebuffCard
## Dissonance: Damage Down 25% for 2 turns.

@export var damage_down: DamageDown          # DamageDown.tres
@export_range(0.05, 0.75) var amount: float = 0.25
@export var duration: int = 2


func _execute(_player: Stat_Manager, targets: Array[Node]) -> void:
	if not damage_down:
		return
	var enemies: Array[Node] = []
	for t in targets:
		if t is EnemyView:
			enemies.append(t)
	if enemies.is_empty():
		return
	var effect := damage_down.duplicate() as DamageDown
	effect.amount = amount
	_apply_status(effect, enemies, duration)
