extends Card
@export var base_damage: int
@export var blood_tax: int
@export var StatsScaled: StatInstance
@export var damage_type: DamageType

func apply_effect(targets: Array[Node]) -> void:
	if targets.is_empty():
		return
	var tree = targets[0].get_tree()
	var player := tree.get_first_node_in_group('player') as Stat_Manager
	if not player:
		return
	player.Player.true_take_damage(blood_tax)

	var total := _calculate_total(player.Player)
	var deal_damage := AttackEffect.new()
	deal_damage.damage_type = damage_type
	deal_damage.amount = total
	deal_damage.activate(targets)

	var target := targets[0] as EnemyView
	if target and target.Enemy and target.Enemy.Entity:
		var syphon := _find_blood_syphon(target.Enemy.Entity.ActiveEffects)
		if syphon:
			var bonus_damage := AttackEffect.new()
			bonus_damage.damage_type = damage_type
			bonus_damage.amount = syphon.current_duration
			bonus_damage.activate(targets)

func _find_blood_syphon(effects: Array) -> BloodSyphon:
	for effect in effects:
		if effect is BloodSyphon:
			return effect
	return null

func _calculate_total(character: CharacterInstance) -> int:
	if character:
		var index := character.stats.find(StatsScaled)
		var bonus := 0
		if index != -1:
			bonus = character.stats[index].stat_scaling_value
		return base_damage + bonus + character.get_attack_bonus()
	else:
		return 0

func get_description(character: CharacterInstance) -> String:
	var total := _calculate_total(character)
	return Description.replace("{scaled}", str(total))

func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var total := _calculate_total(character)
	var enemies : Array[EnemyBattlerStats] = []
	for t in live_targets:
		var entity := _resolve_enemy_entity(t)
		if entity:
			enemies.append(entity)

	if enemies.is_empty():
		return get_description(character)

	var all_resistant := true
	var all_vulnerable := true
	for e in enemies:
		var state := e.get_resistance_state(damage_type)
		all_resistant = all_resistant and state == EnemyBattlerStats.RESISTANCE_STATE.RESISTANT
		all_vulnerable = all_vulnerable and state == EnemyBattlerStats.RESISTANCE_STATE.VULNERABLE

	if all_resistant or all_vulnerable:
		Events.hide_enemy_resistances.emit()
		var shown := enemies[0].calculate_type_adjusted_damage(total, damage_type)
		var syphon := _find_blood_syphon(enemies[0].ActiveEffects)
		if syphon:
			shown += enemies[0].calculate_type_adjusted_damage(syphon.current_duration, damage_type)
		return Description.replace("{scaled}", str(shown))

	Events.reveal_enemy_resistances.emit(damage_type, enemies)
	return Description.replace("{scaled}", str(total))

func _resolve_enemy_entity(node: Node) -> EnemyBattlerStats:
	var current := node
	while current:
		if current is EnemyView:
			return current.Enemy.Entity as EnemyBattlerStats
		current = current.get_parent()
	return null
