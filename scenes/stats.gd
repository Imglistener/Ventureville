class_name Stats extends Node

const damage_types : Array = ["Physical", "Psychic" , "Blood", "Dark"]

var levels : Array = [1.1, 1.05, 1.05, 1.05, 1.05, 1.1]

var player_stats : Dictionary = {
	"Health": 1,
	"Strength": 1,
	"Blood" : 1,
	"Entropy": 1,
	"Influence": 1,
	"Focus": 1
}
var loadouts: Dictionary = {
	"Hemomancer"	: [1, 1, 4, 2, 3, 2],
	"Illusionist"	: [1, 1, 1, 1, 6, 2],
	"Dark Mage"		: [1, 1, 2, 4, 4, 4],
	"Tarnished"		: [3, 3, 1, 1, 1, 4]
}

var base_stats: Dictionary = {	
	"Health": 100,
	"Strength": 1,
	"Blood" : 1,
	"Entropy": 1,
	"Influence": 1,
	"Focus": 100
}

func level_up_scaling() -> Array:
	var scaled_results: Array = []
	
	# Mapping stat names to their specific index in the 'levels' array
	var index_map = {
		"Health": 0, "Strength": 1, "Blood": 2, 
		"Entropy": 3, "Influence": 4, "Focus": 5
	}
	for stat_name in player_stats:
		var stat_value = player_stats[stat_name]
		var idx = index_map[stat_name]
		match stat_name:
			"Health":
				var final_val: int = base_stats["Health"] * levels[0] * (1 + 0.1 * (player_stats[stat_name] - 1))
				scaled_results.append(final_val)
				print(scaled_results)
			"Strength":
				var final_val: int = base_stats["Strength"] * levels[1] * (1 + 0.1 * (player_stats[stat_name] - 1))
				scaled_results.append(final_val)
				print(scaled_results)
	return scaled_results

func get_damagevalue(base_element: String, base_damage: int) -> int:
	# Match handles the "Physical", "Psychic", etc. logic efficiently
	match base_element:
		"Physical":
			return base_damage * player_stats["Strength"]
		"Psychic":
			return base_damage * player_stats["Influence"]
		"Blood":
			return base_damage * player_stats["Blood"]
		"Dark":
			return int(base_damage * player_stats["Entropy"] * player_stats["Focus"] / 100.0)
		_:
			return 1
func _ready() -> void:
	level_up_scaling()
