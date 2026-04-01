class_name Player_Attack_Instance extends Player_Action_instance

@export var hit_count : int



func calculate_damage() -> int:
		var total_damage		= scaling_value + base_damage
		return total_damage

func deal_damage(user : Node, target: Combat_Entity) -> void:
	var amount = calculate_damage()
	var hits = split_multi_hit_damage(amount, hit_count, hit_count*2)
	for hit in hits:
		damage_enemy(target, hit)
		await user.get_tree().create_timer(0.15).timeout
		
		
func split_multi_hit_damage(total_damage: int, hit_count: int, bonus: int = 4) -> Array:
	if hit_count <= 0:
		return []
	if hit_count == 1:
		return [total_damage]
	var base = (total_damage - bonus) / hit_count
	
	var hits: Array = []
	
	# First (n-1) hits
	for i in range(hit_count - 1):
		hits.append(base)
	
	# Final hit
	hits.append(base + bonus)
	
	# Fix rounding issues
	var current_total = 0
	for h in hits:
		current_total += h
	
	var diff = total_damage - current_total
	hits[hit_count - 1] += diff
	
	return hits
	
func apply_effect(player : Node, target : Combat_Entity):
	deal_damage(player , target)
	player.update_battle_history_on_action(self)
