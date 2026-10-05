class_name AttackCard extends Card

@export_group("Attack")
@export var base_damage: int
@export var StatsScaled: StatInstance
@export var damage_type: DamageType


func _init() -> void:
	type = Type.ATTACK
	match attribute:
		CardAttribute.Hemomancy:
			StatsScaled = preload("uid://bqgopm3elq147")
		CardAttribute.Entromancy:
			StatsScaled = preload("uid://ceoqilwthbnl5")
		CardAttribute.Phonomancy:
			StatsScaled = preload("uid://claek5dwbffxw")
		CardAttribute.Somatomancy:
			StatsScaled = preload("uid://cr5xuv3tmjx6m")

# ------------------------------------------------------------------ damage

func _calculate_total(character: CharacterInstance) -> int:
	if not character:
		return 0
	var bonus := 0
	var index := character.stats.find(StatsScaled)
	if index != -1:
		bonus = character.stats[index].stat_scaling_value
		print(name, " | Base Damage: " , base_damage, " Scaled stat Damage: ", bonus, " Damage Multiplier: ", str(character.get_attack_bonus()))
	
	return int((base_damage + bonus) * character.get_attack_bonus())

func _deal_damage(targets: Array[Node], amount: int) -> void:
	var effect := AttackEffect.new()
	effect.damage_type = damage_type
	effect.amount = amount
	effect.activate(targets)


# ------------------------------------------------------------------ descriptions

func get_description(character: CharacterInstance) -> String:
	return Description.replace("{scaled}", str(_calculate_total(character)))

## apply_resistance == true -> return the number after the enemy's resist/vuln modifier.
func _preview_value(character: CharacterInstance, enemy: EnemyBattlerStats, apply_resistance: bool) -> int:
	var total := _calculate_total(character)
	return enemy.calculate_type_adjusted_damage(total, damage_type) if apply_resistance else total

func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return get_description(character)

	var all_resistant := true
	var all_vulnerable := true
	for e in enemies:
		var state := e.get_resistance_state(damage_type)
		all_resistant = all_resistant and state == EnemyBattlerStats.RESISTANCE_STATE.RESISTANT
		all_vulnerable = all_vulnerable and state == EnemyBattlerStats.RESISTANCE_STATE.VULNERABLE

	# Every target reacts the same way, so one adjusted number is accurate.
	if all_resistant or all_vulnerable:
		Events.hide_enemy_resistances.emit()
		return Description.replace("{scaled}", str(_preview_value(character, enemies[0], true)))

	# Mixed targets: show the base number and let the resist icons explain the difference.
	Events.reveal_enemy_resistances.emit(damage_type, enemies)
	return Description.replace("{scaled}", str(_preview_value(character, enemies[0], false)))
