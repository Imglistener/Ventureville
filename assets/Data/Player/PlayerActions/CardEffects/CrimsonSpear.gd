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
