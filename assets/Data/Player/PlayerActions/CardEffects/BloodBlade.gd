extends Card

@export var base_damage: int
@export var base_cost : int
@export var StatsScaled: StatInstance
@export var AppliedEffect: StatusEffect
@export var damage_type: DamageType

var total : int
func apply_effect(targets : Array[Node]) -> void:
	var enemy = targets[0] as EnemyView
	if enemy:
		var tree = targets[0].get_tree()
		var player = tree.get_first_node_in_group('player') as Stat_Manager
		var index = player.Player.stats.find(StatsScaled)
		var damage_bonus = player.Player.stats[index] as StatInstance
		if damage_bonus:
			damage_bonus = damage_bonus.stat_scaling_value 
			var deal_damage = AttackEffect.new()
			deal_damage.damage_type = damage_type
			deal_damage.amount = total
			player.Player.true_take_damage(base_cost)
			deal_damage.activate(targets)
			AppliedEffect.current_duration = 3
			var i = randi_range(0, 3)
			for loop in range(i):
				if AppliedEffect.is_applicable(targets):
					AppliedEffect.on_apply(targets)

func get_description(character: CharacterInstance) -> String:
	var index = character.stats.find(StatsScaled)
	var bonus = character.stats[index].stat_scaling_value + character.buff_damage_modifier
	total = base_damage + bonus
	return Description.replace("{scaled}", str(total))
