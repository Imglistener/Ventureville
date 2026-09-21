extends Card
@export var blood_tax: int
@export var fixed_damage: int
@export var base_syphon_amount: int
@export var bonus_syphon_amount: int
@export var damage_type: DamageType
@export var AppliedEffect: StatusEffect

func apply_effect(targets: Array[Node]) -> void:
	if targets.is_empty():
		return
	var tree = targets[0].get_tree()
	var player := tree.get_first_node_in_group('player') as Stat_Manager
	if not player:
		return
	player.Player.true_take_damage(blood_tax)

	var deal_damage := AttackEffect.new()
	deal_damage.damage_type = damage_type
	deal_damage.amount = fixed_damage
	deal_damage.activate(targets)

	var syphon_amount := base_syphon_amount
	var target := targets[0] as EnemyView
	if target and target.Enemy and target.Enemy.Entity:
		if _find_blood_syphon(target.Enemy.Entity.ActiveEffects):
			syphon_amount += bonus_syphon_amount

	if AppliedEffect and AppliedEffect.is_applicable(targets):
		AppliedEffect.on_apply(targets, syphon_amount)

func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description

	var entity := enemies[0]
	var state := entity.get_resistance_state(damage_type)
	var shown := fixed_damage
	if state == EnemyBattlerStats.RESISTANCE_STATE.NEUTRAL:
		Events.hide_enemy_resistances.emit()
	else:
		Events.reveal_enemy_resistances.emit(damage_type, enemies)
		shown = entity.calculate_type_adjusted_damage(fixed_damage, damage_type)

	var syphon_amount := base_syphon_amount
	if _find_blood_syphon(entity.ActiveEffects):
		syphon_amount += bonus_syphon_amount

	return Description + "\n(Deals %d Blood Damage) (Inflicts %d Blood Syphon)" % [shown, syphon_amount]

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
