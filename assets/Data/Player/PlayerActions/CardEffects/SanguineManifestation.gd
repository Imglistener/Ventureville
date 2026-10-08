extends DebuffCard

@export var damage_down_effect: DamageDown
@export var damage_down_per_stack: float = 0.05
@export var damage_down_duration: int = 1
@export var draw_per_enemy: int = 1

func _syphon_stacks(node: Node) -> int:
	var entity := _entity_of(node)
	if not entity:
		return 0
	var syphon := _find_status(entity.ActiveEffects, BloodSyphon) as BloodSyphon
	return syphon.current_duration if syphon else 0

func _execute(_player: Stat_Manager, targets: Array[Node]) -> void:
	var syphoned_enemies := 0
	for view in targets:
		if view is not EnemyView:
			continue
		var stacks := _syphon_stacks(view)
		if stacks <= 0:
			continue
		syphoned_enemies += 1
		var effect := damage_down_effect.duplicate() as DamageDown
		effect.amount = damage_down_per_stack * stacks
		var single: Array[Node] = [view]
		_apply_status(effect, single, damage_down_duration)

	if syphoned_enemies > 0:
		var draw := DrawEffect.new()
		draw.amount = syphoned_enemies * draw_per_enemy
		draw.activate(targets)

func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	var count := 0
	for view in live_targets:
		if view is EnemyView and _syphon_stacks(view) > 0:
			count += 1
	return Description + "\n(Draw %d)" % (count * draw_per_enemy)
