class_name stat extends Resource

@export var stat_name: String
@export var stat_value: int
@export var cap_1: int = 20
@export var cap_2: int = 40

@export var scaling_1: float = 2.0
@export var scaling_2: float = 1.0
@export var scaling_3: float = 0.5
@export var resist_max: float
@export var resist_stat_cap: float



func calculate_scaling(stat_name: stat_instance, starting_level: int = stat_name.Constant_value) -> float:
	var value := 0.0
	var true_stat_value = max((stat_value - starting_level), 0)

	if stat_value <= stat_name.cap_1:
		value += true_stat_value * stat_name.scaling_1

	elif stat_value <= stat_name.cap_2:
		value += stat_name.cap_1 * stat_name.scaling_1
		value += (true_stat_value - stat_name.cap_1) * stat_name.scaling_2

	else:
		value += stat_name.cap_1 * stat_name.scaling_1
		value += (stat_name.cap_2 - stat_name.cap_1) * stat_name.scaling_2
		value += (true_stat_value - stat_name.cap_2) * stat_name.scaling_3
	print(stat_name.stat_name, ":" , value)
	return value
	
func calculate_resistance(used_stat : stat_instance, stat_value: int, starting_level : int = used_stat.Constant_value)-> float:
	var true_stat_value = max((stat_value - starting_level), 0)
	var resistance :	float	= (true_stat_value / resist_stat_cap) * resist_max
	resistance					= clamp(resistance, 0.0, resist_max)
	return resistance
