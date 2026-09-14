class_name Loadout extends Resource

@export_multiline var loadout_name : String
@export var loadout_stats : Array[StatInstance]

@export var health_level : int
@export var sanity_level : int
@export var blood_level : int
@export var influence_level: int
@export var entropy_level: int
@export var strength_level: int
@export var character_portrait : Texture2D

func setup_loadout() -> Array[StatInstance]:
	var loadout = loadout_stats.duplicate()
	loadout[0].stat_level = health_level
	loadout[1].stat_level = sanity_level
	loadout[2].stat_level = blood_level
	loadout[3].stat_level = entropy_level
	loadout[4].stat_level = influence_level
	loadout[5].stat_level = strength_level
	return loadout

func get_health_level() -> int:
	for i in setup_loadout():
		if i.stat_name == StatInstance.STATS.HEALTH:
			return i.stat_level
		else:
			continue
	return 0

func get_sanity_level() -> int:
	for i in setup_loadout():
		if i.stat_name == StatInstance.STATS.SANITY:
			return i.stat_level
		else:
			continue
	return 0

func get_blood_level() -> int:
	for i in setup_loadout():
		if i.stat_name == StatInstance.STATS.BLOOD:
			return i.stat_level
		else:
			continue
	return 0
