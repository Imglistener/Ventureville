extends Card
@export var base_damage: int
@export var blood_tax: int
@export var StatsScaled: StatInstance
@export var damage_type: DamageType
@export var AppliedEffect: StatusEffect
@export var syphon_duration: int = 2

func apply_effect(targets: Array[Node]) -> void:
	if targets.is_empty():
		return
	var tree = targets[0].get_tree()
	var player := tree.get_first_node_in_group('player') as Stat_Manager
	if not player:
		return
	player.Player.true_take_damage(blood_tax)

	var total := _calculate_total(player.Player)
	var target := targets[0] as EnemyView
	var was_alive := target and target.Enemy and target.Enemy.Entity and target.Enemy.Entity.current_health > 0

	var deal_damage := AttackEffect.new()
	deal_damage.damage_type = damage_type
	deal_damage.amount = total
	deal_damage.activate(targets)

	if AppliedEffect and AppliedEffect.is_applicable(targets):
		AppliedEffect.on_apply(targets, syphon_duration)

	if was_alive and target.Enemy.Entity.current_health <= 0:
		player.Player.heal(blood_tax)

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
