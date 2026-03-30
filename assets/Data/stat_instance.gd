class_name stat_instance extends stat

@export var stat_description : String
@export var Constant_value: int = 1
@export var Associated_Damage_Type: Damage_Type
@export var BASE 			: int 
 
var Current_Value : int
var raw_scaling_value : float
var raw_resistance_value: float 

func get_bars_value(target_stat: stat_instance) -> int:
	get_raw_scaling_value(target_stat)
	if target_stat.stat_name == "Health" or target_stat.stat_name == "Sanity": 
		var Max_value = int(target_stat.raw_scaling_value + BASE)
		return Max_value
	else: 
		return 0
func get_current_value(target_stat: stat_instance) -> int:
	if Current_Value == 0:
		Current_Value = get_bars_value(target_stat)
		return Current_Value
	else:
		return Current_Value
		
func get_raw_scaling_value(target_stat : stat_instance) -> int:
	raw_scaling_value = calculate_scaling(target_stat)
	return int(raw_scaling_value)
