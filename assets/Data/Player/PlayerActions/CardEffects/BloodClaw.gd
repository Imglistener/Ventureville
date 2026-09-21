extends Card

@export var BaseDamage: int
@export var damage_type: DamageType
@export var VFX : PackedScene

func apply_effect(targets : Array[Node]) -> void:
	var damage_effect := AttackEffect.new()
	damage_effect.amount = BaseDamage
	damage_effect.damage_type = damage_type
	damage_effect.activate(targets)
	var Visual = VFX.instantiate()
	targets[0].add_child(Visual)
	Visual.animation_player.play('BloodClaw')
	var ended = func():
		Visual.queue_free()
	Visual.animation_player.animation_finished.connect(
		ended.unbind(1)
	)

func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description

	var entity := enemies[0]
	Events.reveal_enemy_resistances.emit(damage_type, enemies)
	var shown := entity.calculate_type_adjusted_damage(BaseDamage, damage_type)
	return Description + "\n(Deals %d Blood Damage)" % shown

func _resolve_enemies(live_targets: Array[Node]) -> Array[EnemyBattlerStats]:
	var enemies: Array[EnemyBattlerStats] = []
	for t in live_targets:
		var entity := _resolve_enemy_entity(t)
		if entity:
			enemies.append(entity)
	return enemies

func _resolve_enemy_entity(node: Node) -> EnemyBattlerStats:
	var current := node
	while current:
		if current is EnemyView:
			return current.Enemy.Entity as EnemyBattlerStats
		current = current.get_parent()
	return null
