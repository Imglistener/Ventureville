extends Card
@export var damage_type: DamageType
@export var blood_tax : int

func apply_effect(targets : Array[Node]) -> void:
	if targets.is_empty():
		return
	var tree = targets[0].get_tree()
	var player := tree.get_first_node_in_group('player') as Stat_Manager
	if not player:
		return
	player.Player.true_take_damage(blood_tax)
	for enemy in targets:
		if enemy is EnemyView:
			for effect in enemy.Enemy.Entity.ActiveEffects:
				if effect is BloodSyphon:
					for multiplier in range(2):
						var damage = AttackEffect.new()
						damage.amount = effect.current_duration + player.Player.get_attack_bonus()
						damage.damage_type = damage_type
						damage.activate(targets)
					return
				for multiplier in range(2):
					var damage = AttackEffect.new()
					damage.amount = player.Player.get_attack_bonus()
					damage.damage_type = damage_type
					damage.activate(targets)
				
func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description

	var entity := enemies[0]
	var syphon := _find_blood_syphon(entity.ActiveEffects)
	var bonus := character.get_attack_bonus() if character else 0

	Events.reveal_enemy_resistances.emit(damage_type, enemies)

	if syphon:
		var per_hit := syphon.current_duration + bonus
		var adjusted := entity.calculate_type_adjusted_damage(per_hit, damage_type)
		return Description + "\n(Deals %d Blood Damage)" % (adjusted*2)
	else:
		var adjusted := entity.calculate_type_adjusted_damage(bonus, damage_type)
		return Description + "\n(Deals %d Blood Damage)" % (adjusted*2)

func _find_blood_syphon(effects: Array) -> BloodSyphon:
	for effect in effects:
		if effect is BloodSyphon:
			return effect
	return null

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
