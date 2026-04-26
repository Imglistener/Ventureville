class_name StatInstance extends Resource

signal StatChanged
enum STATS{HEALTH, SANITY, STRENGTH, INFLUENCE, BLOOD, ENTROPY}

@export_group("Primary Variables")
@export var stat_name 	: STATS
@export var stat_level	: int
@export var BASE_OFFSET	: int = 100

@export_group("Advanced Variables")
@export var cap_1: int = 20
@export var cap_2: int = 40
@export var scaling_1: float = 2.0
@export var scaling_2: float = 1.0
@export var scaling_3: float = 0.5
@export var resist_max: float
@export var resist_stat_cap: float

var stat_total_value		: int :
	get:
		if stat_name == STATS.HEALTH or stat_name == STATS.SANITY:
			return stat_scaling_value + BASE_OFFSET
		else:
			return stat_scaling_value

var stat_scaling_value		: int : get = get_scaling_value
var stat_resistance_value	: int : get = get_resistance_value


func get_scaling_value() -> int:
	var value := 0.0
	var true_stat_value = max((stat_level - 10), 0)
	if true_stat_value <= self.cap_1:
		# Tier 1: all points at scaling_1
		value += true_stat_value * self.scaling_1
	elif true_stat_value <= self.cap_2:
		# Tier 2: first cap_1 points at scaling_1, rest at scaling_2
		value += self.cap_1 * self.scaling_1
		value += (true_stat_value - self.cap_1) * self.scaling_2
	else:
		# Tier 3: diminishing returns
		value += self.cap_1 * self.scaling_1
		value += (self.cap_2 - self.cap_1) * self.scaling_2
		value += (true_stat_value - self.cap_2) * self.scaling_3
	return int(value)

func get_resistance_value() -> int:
	var true_stat_value = max((stat_level - 10), 0)
	
	# Protect against division by zero
	if resist_stat_cap <= 0:
		return 0
	
	var resistance: float = (true_stat_value / resist_stat_cap) * resist_max
	resistance = clamp(resistance, 0.0, resist_max)
	
	return int(resistance)
