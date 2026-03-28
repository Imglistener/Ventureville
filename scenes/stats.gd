class_name Stats extends Node

const damage_types : Array = ["Physical", "Psychic" , "Blood", "Dark"]

var levels : Array = [1.1, 1.05, 1.05, 1.05, 1.05, 1.1]

var player_stats : Dictionary = {
	"Health": 1,
	"Strength": 20,
	"Blood" : 20,
	"Entropy": 10,
	"Influence": 10,
	"Focus": 1
}
const loadouts: Dictionary = {
	"Hemomancer"	: [10, 10, 14, 12, 13, 12],
	"Illusionist"	: [10, 10, 10, 10, 16, 12],
	"Dark Mage"		: [1, 10, 12, 14, 14, 4],
	"Tarnished"		: [3, 13, 10, 10, 10, 4]
}

const  base_stats: Dictionary = {	
	"Health": 100,
	"Strength": 1,
	"Blood" : 1,
	"Entropy": 1,
	"Influence": 1,
	"Focus": 100
}
func level_up(chosen_stat: String, amount: int, current_player_stats: Dictionary) -> void:
	if chosen_stat in player_stats:
		player_stats[chosen_stat] = player_stats[chosen_stat] + amount
	else:
		pass



func level_scaling(player_stats, levels, stat_name: String) -> float:
	var index_map = {
		"Health": 0, "Strength": 1, "Blood": 2, 
		"Entropy": 3, "Influence": 4, "Focus": 5
	}
	var idx = index_map[stat_name]
	var final_val: float = 1.0
	match stat_name:
		"Health":
			final_val = base_stats["Health"] * levels[idx] * (1 + 0.1 * (player_stats[idx] - 1))
		"Strength":
			final_val = round(base_stats["Strength"] * levels[idx] * (1 + 0.05 * (player_stats[idx] - 1))*10)/10
		"Blood":
			final_val= round(base_stats["Blood"] * levels[idx] * (1 + 0.04 * (player_stats[idx] - 1))*10)/10
		"Entropy":
			final_val = round(base_stats["Entropy"] * levels[idx] * (1 + 0.04 * (player_stats[idx] - 1))*10)/10		
		"Influence": 
			final_val = round(base_stats["Influence"] * levels[idx] * (1 + 0.04 * (player_stats[idx] - 1))*10)/10
		"Focus":
			final_val = base_stats["Focus"] * levels[idx] * (1 + 0.1 * (player_stats[idx] - 1))
		_:
			final_val = 1.0
	return final_val
		

func get_damagevalue(base_element: String, base_damage: int) -> int:
	# Match handles the "Physical", "Psychic", etc. logic efficiently
	match base_element:
		"Physical":
			return base_damage * level_scaling(player_stats, levels, "Strength")
		"Psychic":
			return base_damage * level_scaling(player_stats, levels, "Influence")
		"Blood":
			return base_damage * level_scaling(player_stats, levels, "Blood")
		"Dark":
			return int(base_damage * level_scaling(player_stats, levels, "Entropy") * player_stats["Focus"] / 100.0)
		_:
			return 1
func _ready() -> void:
	pass
