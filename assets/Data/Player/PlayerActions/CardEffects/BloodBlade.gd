extends Card
@export var base_damage: int
@export var base_cost : int
@export var StatsScaled: StatInstance
@export var AppliedEffect: StatusEffect      # BloodSyphon.tres
@export var RegenEffect: StatusEffect        # Regeneration.tres
@export var damage_type: DamageType

func apply_effect(targets: Array[Node]) -> void:
	if targets.is_empty():
		return
	var enemy := targets[0] as EnemyView
	if not enemy:
		return

	var tree = targets[0].get_tree()
	var player := tree.get_first_node_in_group('player') as Stat_Manager
	if not player:
		return

	var total := _calculate_total(player.Player)

	var deal_damage := AttackEffect.new()
	deal_damage.damage_type = damage_type
	deal_damage.amount = total
	player.Player.true_take_damage(base_cost)
	deal_damage.activate(targets)

	var applied_duration := 3
	var apply_count := randi_range(1, 3)
	for i in range(apply_count):
		if AppliedEffect.is_applicable(targets):
			AppliedEffect.current_duration = applied_duration
			AppliedEffect.on_apply(targets)
			

	if apply_count > 0 and RegenEffect:
		var self_target: Array[Node] = [player]
		RegenEffect.on_apply(self_target, apply_count)
		
func _calculate_total(character: CharacterInstance) -> int:
	var index := character.stats.find(StatsScaled)
	var bonus := 0
	if index != -1:
		bonus = character.stats[index].stat_scaling_value
	return base_damage + bonus

func get_description(character: CharacterInstance) -> String:
	var total := _calculate_total(character)
	return Description.replace("{scaled}", str(total))
